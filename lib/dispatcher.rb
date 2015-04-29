class Dispatcher
  def email_approver(approval)
    approval.create_api_token!
    send_notification_email(approval)
  end

  def email_observers(cart)
    cart.observations.each do |observation|
      CommunicartMailer.cart_observer_email(observation.user_email_address, cart).deliver
    end
  end

  def email_sent_confirmation(cart)
    CommunicartMailer.proposal_created_confirmation(cart).deliver
  end

  def deliver_new_cart_emails(cart)
    self.email_observers(cart)
    self.email_sent_confirmation(cart)
  end

  def requires_approval_notice?(approval)
    true
  end

  def on_proposal_rejected(proposal)
    cart = proposal.cart
    rejection = cart.rejections.first
    # @todo rewrite this email so a "rejection approval" isn't needed
    CommunicartMailer.approval_reply_received_email(rejection).deliver
    self.email_observers(cart)
  end

  def on_approval_approved(approval)
    if self.requires_approval_notice?(approval)
      CommunicartMailer.approval_reply_received_email(approval).deliver
    end

    self.email_observers(approval.cart)
  end

  def on_comment_created(comment)
    comment.listeners.each{|user|
      CommunicartMailer.comment_added_email(comment, user.email_address).deliver
    }
  end

  def on_proposal_update(proposal)
  end

  # todo: replace with dynamic dispatch
  def self.initialize_dispatcher(proposal)
    case proposal.flow
    when 'parallel'
      ParallelDispatcher.new
    when 'linear'
      # @todo: dynamic dispatch for selection
      if proposal.client == "ncr"
        NcrDispatcher.new
      else
        LinearDispatcher.new
      end
    end
  end

  def self.deliver_new_cart_emails(cart)
    dispatcher = self.initialize_dispatcher(cart.proposal)
    dispatcher.deliver_new_cart_emails(cart)
  end

  def self.on_proposal_rejected(proposal)
    dispatcher = self.initialize_dispatcher(proposal)
    dispatcher.on_proposal_rejected(proposal)
  end

  def self.on_approval_approved(approval)
    dispatcher = self.initialize_dispatcher(approval.proposal)
    dispatcher.on_approval_approved(approval)
  end

  def self.on_comment_created(comment)
    dispatcher = self.initialize_dispatcher(comment.proposal)
    dispatcher.on_comment_created(comment)
  end

  def self.email_approver(approval)
    dispatcher = self.initialize_dispatcher(approval.proposal)
    dispatcher.email_approver(approval)
  end

  def self.on_proposal_update(proposal)
    dispatcher = self.initialize_dispatcher(proposal)
    dispatcher.on_proposal_update(proposal)
  end

  private

  def send_notification_email(approval)
    email = approval.user_email_address
    CommunicartMailer.cart_notification_email(email, approval).deliver
  end
end
