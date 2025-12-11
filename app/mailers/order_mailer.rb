class OrderMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.received.subject
  #

  default from: "Sam Ruby <depot@example.com>"

  def received(order)
    @order = order
    
    mail to: order.email, subject: "Spooky Store Order Confirmation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.shipped.subject
  #
  def shipped(order)
    @order = order
    
    mail to: order.email, subject: "Pragmatic Store Order Shipped"
  end
end
