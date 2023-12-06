class PasswordsController < ApplicationController
  before_action :set_password, except: %i[index new create]
  before_action :require_editable_permission, only: %i[edit update]
  before_action :require_deletable_permission, only: [:destroy]

  def index
    @passwords = current_user.passwords
  end

  def show; end

  def new
    @password = Password.new
  end

  def edit; end

  def create
    @password = Password.new(password_params)
    @password.user_passwords.new(user: current_user, role: 'Owner')
    if @password.save
      redirect_to @password, notice: 'Password successfully created!'
    else
      flash.now[:alert] = 'Password could not be created!'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @password.update(password_params)
      redirect_to @password, notice: 'Password successfully updated!'
    else
      flash.now[:alert] = 'Password could not be updated!'
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    if @password.destroy
      redirect_to passwords_path, notice: 'Password successfully deleted!'
    else
      redirect_to @password, alert: 'Failed to delete password!'
    end
  end

  private

  def password_params
    params.require(:password).permit(:password, :username, :url)
  end

  def set_password
    @password = current_user.passwords.find(params[:id])
  end

  def require_editable_permission
    redirect_to @password, notice: "You don't have permission to do this!" unless current_user_password.editable?
  end

  def require_deletable_permission
    redirect_to @password, notice: "You don't have permission to do this!" unless current_user_password.destroyable?
  end
end
