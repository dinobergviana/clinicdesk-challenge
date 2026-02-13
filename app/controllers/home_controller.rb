class HomeController < ApplicationController
  def index
    render json: { message: "API funcionando 🚀" }
  end
end
