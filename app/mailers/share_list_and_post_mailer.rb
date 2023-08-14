class ShareListAndPostMailer < ApplicationMailer
    def share_list_email(user, list,recipient_email)
        @user = user
        @list = list
        mail(to: recipient_email, subject: "You've received a shared list!")
    end
    def share_post_email(user, post, recipient_email, message)
        @user = user
        @post = post
        @message = message
        mail(to: recipient_email, subject: "You've received a shared post!")
    end
end
