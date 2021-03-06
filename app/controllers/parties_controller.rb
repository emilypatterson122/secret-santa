class PartiesController < ApplicationController
  before_action :set_party, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :organizer?, only: [:show, :edit, :update, :destroy]

  # GET /parties
  # GET /parties.json
  def index
    @parties = Party.where(organizer_id: current_user.id)
    @invitations = current_user.invitations
  end

  # GET /parties/1
  # GET /parties/1.json
  def show
    @invitation = Invitation.new(:party => @party)
  end

  # GET /parties/new
  def new
    @party = Party.new
  end

  # GET /parties/1/edit
  def edit
  end

  # POST /parties
  # POST /parties.json
  def create
    @user = current_user
    @party = @user.parties.create(party_params)

    respond_to do |format|
      if @party.save
        @party.create_location(location_params[:location_attributes])
        format.html { redirect_to @party, notice: 'Party was successfully created.' }
        format.json { render :show, status: :created, location: @party }
      else
        format.html { render :new }
        format.json { render json: @party.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parties/1
  # PATCH/PUT /parties/1.json
  def update
    respond_to do |format|
      if @party.update(party_params)
        @party.location.update_attributes(location_params[:location_attributes])
        format.html { redirect_to @party, notice: 'Party was successfully updated.' }
        format.json { render :show, status: :ok, location: @party }
      else
        format.html { render :edit }
        format.json { render json: @party.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parties/1
  # DELETE /parties/1.json
  def destroy
    @party.destroy
    respond_to do |format|
      format.html { redirect_to parties_url, notice: 'Party was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def draw_names
    @party = Party.find(params[:id])
    @party.draw_names

    redirect_to @party, notice: 'Names Drawn Successfully.'
  end

  def send_invitations
    @party = Party.find(params[:id])
    @party.invitations.each do |invite|
      invite.send_invitation
    end
    redirect_to @party, notice: 'Invitations Successfully Sent!'
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_party
      @party = Party.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def party_params
      params.require(:party).permit(:theme, :date, :time, :rsvp_deadline, :address, :spending_limit)
    end

    def location_params
      params.require(:party).permit(:location_attributes =>[:address, :latitude, :longitude])
    end

    def organizer?
      @party = Party.find(params[:id])
      if @party.organizer != current_user
        redirect_to root_url, notice: "You are not the party organizer"
      end
    end
end
