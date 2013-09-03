App.addChild('Payment', _.extend({
  el: '#main_content[data-action="create"][data-controller-name="backers"] #payment',

  events: {
    'change .payment_menu input' : 'showPaymentContent'
  },

  showPaymentContent: function(e){
    $('#info_box strong.total_value').text($(e.target).data('value-with-taxs'));
    $('.payments_type').hide();
    payment = '.payments_type#' + $(e.target).val() + '_payment'
    $(payment).fadeIn();

    if($.trim($(payment).html()) == '' && $(payment).data('path')){
      $.get($(payment).data('path')).success(function(data){
        $(payment).html(data);
      });
    }
  },

  activate: function(){
    this.$('.payment_menu input:first').attr('checked', true);
    this.showPaymentContent({target: '#payment_method_credit_card_net'});
  }
}));

