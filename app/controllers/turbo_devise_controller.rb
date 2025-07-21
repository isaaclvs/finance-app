class TurboDeviseController < ApplicationController
  class Responder < ActionController::Responder
    def to_turbo_stream
      controller.render(options.merge(formats: :html))
    rescue ActionView::MissingTemplate => error
      if get?
        raise error
      elsif has_errors? && default_action
        render rendering_options.merge(formats: :html, status: :unprocessable_entity)
      else
        begin
          redirect_to navigation_location
        rescue NoMethodError => e
          if e.message.include?("users_url")
            controller.redirect_to controller.new_user_session_path
          else
            raise e
          end
        end
      end
    end

    def to_html
      if has_errors? && default_action
        render rendering_options.merge(status: :unprocessable_entity)
      else
        begin
          super
        rescue NoMethodError => e
          if e.message.include?("users_url")
            controller.redirect_to controller.new_user_session_path
          else
            raise e
          end
        end
      end
    end
  end

  self.responder = Responder
  respond_to :html, :turbo_stream

  protected

  def respond_with(resource, _opts = {})
    if resource.persisted?
      redirect_to after_sign_in_path_for(resource)
    else
      if resource.errors.empty? && controller_name == "sessions" && action_name == "create"
        flash.now[:alert] = "Invalid email or password."
      end
      begin
        super
      rescue NoMethodError => e
        if e.message.include?("users_url")
          render "new", status: :unprocessable_entity, formats: [ :html ]
        else
          raise e
        end
      end
    end
  end
end
