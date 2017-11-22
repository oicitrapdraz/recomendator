class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  #before_action :authenticate

  # GET /users
  # GET /users.json
  def index
    @users = User.all
    password = "TPSW_servidor"
    @users.each do |user|
      user.password = AESCrypt.decrypt(user.password, password)
    end
  end

  def login
    key = "TPSW_servidor"
    @user = User.find_by(email: credential_params[:email])
    email = credential_params[:email]
    pass = credential_params[:password]
    logger.info(@user)
    @user.password = AESCrypt.decrypt(@user.password, key)
    if email==@user.email && pass == @user.password 
      render :show, status: :ok, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params.except(:preferences))
    types = user_params[:preferences].split(",")
    password = "TPSW_servidor"
    @user.password = AESCrypt.encrypt(@user.password, password)
    #logger.info(@user)
    #logger.info(types)
    if @user.save
    	types.each { |type|
    		pref = Preference.find_by(type_of_place: type)
    		logger.info(pref)
    		if !pref
    			pref = Preference.create([{type_of_place: type}])   			
    		end
    		@user.preferences << pref unless @user.preferences.include?(pref)
    	
    	}
    	render :show, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if @user.update(user_params)
      render :show, status: :ok, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    #User Authentication
    #def authenticate
    #  key = "TPSW_servidor"
    #  email = request.headers["email"]
    #  pass = request.headers["password"]
    #  authenticate_or_request_with_http_basic do |username,password|
    #    @length=User.all
    #    if @length.length > 0
    #      @user = User.find_by(email: email)
    #      if @user 
    #        @user.password = AESCrypt.decrypt(@user.password, key)
    #        email==@user.email && pass == @user.password 
    #      end
    #    end          
      #end
    #end

    def credential_params
      params.require(:user).permit(:email,:password)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name,:email,:password,:android_id,:preferences)
    end
end
