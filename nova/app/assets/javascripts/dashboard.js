document.addEventListener('DOMContentLoaded', function() {
  var html = document.getElementsByTagName('html')[0];
  if(html.className != 'dashboard-controller show-action') {
    return;
  }

  var creditCardForm = document.getElementById('credit-card');
  var stripe = Stripe(creditCardForm.getAttribute('api-key'));
  var elements = stripe.elements();
  var creditCard = elements.create('card');
  var hasCreditCard = creditCardForm.getAttribute('data-found') === 'true';

  var api = {
    query: function(params) {
      var queryString = [];
      for(var key in params) {
        if(params.hasOwnProperty(key)) {
          queryString.push(encodeURIComponent(key) + "=" + encodeURIComponent(params[key]))
        }
      }
      return queryString.join('&');
    },
    get: function(path, params) {
      if(params) {
        path = path + '?' + api.query(params);
      }
      return api.request('get', path);
    },
    post: function(path, params) {
      return api.request('post', path, params);
    },
    put: function(path, params) {
      return api.request('put', path, params);
    },
    delete: function(path, params) {
      return api.request('delete', path, params);
    },
    request: function(method, path, params) {
      var opts = {
        method: method.toUpperCase(),
        credentials: 'same-origin',
        headers: {},
      };

      if(method != 'get' && params) {
        opts.body = JSON.stringify(params);
        opts.headers['Content-Type'] = 'application/json';
      };

      return fetch(path, opts).then(function(response) {
        return response.json();
      });
    },
  };

  var dashboard = new Vue({
    el: '#dashboard',
    data: {
      page: 1,
      currentTab: 'remits',
      chargeForm: 0,
      chargeAmount: 0,
      charges: [],
      recvRemits: [],
      sentRemits: [],
      maxPage: 1,
      hasCreditCard: hasCreditCard,
      creditCardUpdateStatus: false,
      isActiveNewRemitForm: false,
      isChargeConfirm: false,
      updateCreditCardStatus: '',
      updateCreditCardStatusMessage: '',
      target: "",
      user: {
        email: "",
        nickname: "",
        amount: 0
      },
      newRemitRequest: {
        emails: [],
        amount: 0,
      },
    },
    beforeMount: function() {
      var self = this;
      self.page = 1;

      api.get('/api/user').then(function(json) {
        self.user = json;
      });

      api.get('/api/charges').then(function(json) {
        self.charges = json.charges;
        for (var i = 0; i < self.charges.length; i++){
          var strDateTime = self.charges[i]['created_at'];
          var myDate = new Date(strDateTime);
          self.charges[i]['created_at'] = myDate.toLocaleString();
        }
      });

      api.get('/api/remit_requests').
        then(function(json) {
          self.maxPage = json.max_pages
          self.recvRemits = json.remit_requests;
          console.log(self.recvRemits[0].status);
          document.getElementsByClassName('pagination-link')[0].classList.add('is-current')
        });

      setInterval(function() {
        api.get('/api/remit_requests', { page: self.page }).
          then(function(json) {
            self.recvRemits = json.remit_requests;
          });
      }, 5000);
    },
    mounted: function() {
      var form = document.getElementById('credit-card');
      if(form){ creditCard.mount(form); }
    },
    methods: {
      chargeModal: function(amount, event) {
        var self = this;
        self.chargeAmount = parseInt(amount);
        self.isChargeConfirm = true;

      },
      charge: function(event) {
        if(event) { event.preventDefault(); }
        var self = this;

        self.isChargeConfirm = false;
        var amount = self.chargeAmount;
        var self = this;
        api.post('/api/charges', { amount: amount }).
          then(function(json) {

            if(json.status == 'accepted')
              self.user.amount += amount;
            var myDate = new Date(json['created_at']);
            json['created_at'] = myDate.toLocaleString();
            self.charges.unshift(json);
          }).
          catch(function(err) {
            console.error(err);
          });
      },
      registerCreditCard: function(event) {
        if(event) { event.preventDefault(); }

        var self = this;
        stripe.createToken(creditCard).
          then(function(result) {
            return api.post('/api/credit_card', { credit_card: { source: result.token.id }});
          }).
          then(function(result) {
            if (result.last4){
              var last4 = result.last4
              self.hasCreditCard = true;
              self.updateCreditCardStatusMessage = "クレジットカードの変更が完了しました。"
              self.updateCreditCardStatus = 'success';
              document.getElementById('card_status').innerText = '登録済クレジットカードの情報 : 下4桁は' + last4 + 'です。';
            } else {
              self.updateCreditCardStatusMessage = 'エラーが発生しました。';
              self.updateCreditCardStatus = 'failed';
            }

            self.creditCardUpdateStatus = true;
            setTimeout(function(){
              self.creditCardUpdateStatus = false;
            }, 5000)
          });
      },
      addTarget: function(event) {
        if(event) { event.preventDefault(); }

        if(!this.newRemitRequest.emails.includes(this.target)) {
          this.newRemitRequest.emails.push(this.target);
        }
      },
      removeTarget: function(email, event) {
        if(event) { event.preventDefault(); }

        this.newRemitRequest.emails = this.newRemitRequest.emails.filter(function(e) {
          return e != email;
        });
      },
      sendRemitRequest: function(event) {
        if(event) { event.preventDefault(); }
        var self = this;
        api.post('/api/remit_requests', this.newRemitRequest).
          then(function() {
            // [TODO] fix change badge
            self.newRemitRequest = {
              emails: [],
              amount: 0,
            };
            self.target = '';
            self.isActiveNewRemitForm = false;
          });
      },
      accept: function(id, event) {
        if(event) { event.preventDefault(); }
        event.path[1].getElementsByTagName('button')[0].disabled =  "true"; // accept button
        event.path[1].getElementsByTagName('button')[1].disabled =  "true"; // reject button
        console.log('accept')
        var self = this;

        api.post('/api/remit_requests/' + id + '/accept').
          then(function(result) {
            console.log(result)
            self.recvRemits = self.recvRemits.filter(function(r) {
              if(r.id == id) {
                self.amount -= r.amount;
              }
              return true
            });
          });
      },
      reject: function(id, event) {
        if(event) { event.preventDefault(); }
        event.path[1].getElementsByTagName('button')[0].disabled =  "true"; // accept button
        event.path[1].getElementsByTagName('button')[1].disabled =  "true"; // reject button
        console.log('reject')

        var self = this;
        api.post('/api/remit_requests/' + id + '/reject').
          then(function() {
          });
      },
      cancel: function(id, event) {
        event.path[1].getElementsByTagName('button')[0].disabled =  "true"; // cancel button
        if(event) { event.preventDefault(); }
        console.log('cancel')

        var self = this;
        api.post('/api/remit_requests/' + id + '/cancel').
          then(function() {
          });
      },
      updateUser: function(event) {
        if(event) { event.preventDefault(); }

        var self = this;
        api.put('/api/user', { user: this.user }).
          then(function(json) {
            self.user = json;
          });
      },
      jumpRemixPage: function(page, event) {
        var self = this;

        self.updateRemixPage(page)
      },
      updateRemixPage: function(next) {
        var self = this;

        api.get('/api/remit_requests', { page: next }).
        then(function(json) {
          self.recvRemits = json.remit_requests;
          document.getElementsByClassName('pagination-link')[self.page-1].classList.remove('is-current')
          document.getElementsByClassName('pagination-link')[next-1].classList.add('is-current')
          self.page = next
        });

      }
    }
  });
});
