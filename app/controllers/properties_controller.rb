class PropertiesController < ApplicationController
  def index
    @properties = Property.includes(:units)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(25)
  end

  def show
    @property = Property.includes(:units).find(params[:id])
  end
end
