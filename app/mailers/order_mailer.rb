class OrderMailer < ApplicationMailer
  default from: "Sam Ruby <depot@example.com>"

  def received(order)
    @order = order
    @line_item_inline_images = {}

    @order.line_items.each_with_index do |item, index|
      images = if item.product.images.attached?
        item.product.images.to_a
      elsif item.product.image.attached?
        [ item.product.image ]
      else
        []
      end
      next if images.empty?

      first_image = images.first
      inline_key = "line_item_#{index + 1}_#{first_image.filename}"
      attachments.inline[inline_key] = first_image.download
      @line_item_inline_images[item.id] = inline_key

      images.drop(1).each_with_index do |image, image_index|
        attachment_key = "line_item_#{index + 1}_extra_#{image_index + 1}_#{image.filename}"
        attachments[attachment_key] = image.download
      end
    end

    I18n.with_locale(@order.user&.language || "en") do
      mail to: order.email, subject: I18n.t("order_mailer.received.subject")
    end
  end

  def consolidated_summary(user)
    @user = user
    @orders = user.orders.includes(line_items: :product)

    I18n.with_locale(user.language.presence || "en") do
      mail to: user.email_address, subject: I18n.t("order_mailer.consolidated_summary.subject")
    end
  end

  def shipped(order)
    @order = order

    mail to: order.email, subject: "Pragmatic Store Order Shipped"
  end
end
