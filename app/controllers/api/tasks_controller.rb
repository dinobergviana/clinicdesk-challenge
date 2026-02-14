module Api
  class TasksController < ApplicationController
    before_action :set_task, only: %i[show update destroy]

    # GET /tasks
    def index
      result = Task.list(params)

      render json: {
        data: result[:records],
        total_records: result[:total],
        per_page: result[:per_page],
        page: result[:page]
      }
    end

    # GET /tasks/:id
    def show
      render json: { data: @task, status: 200 }
    end

    # POST /tasks
    def create
      task = Task.new(task_params)

      if task.save
        render json: { data: task, status: 201 }, status: :created
      else
        render_unprocessable(task)
      end
    end

    # PATCH /tasks/:id
    def update
      if @task.update(task_params)
        render json: { data: @task, status: 200 }
      else
        render_unprocessable(@task)
      end
    end

    # DELETE /tasks/:id
    def destroy
      @task.destroy
      render json: { message: "Task deleted", status: 200 }
    end

    private

    def set_task
      @task = Task.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ["Task not found"] }, status: :not_found
    end

    def task_params
      params.require(:task).permit(
        :title,
        :description,
        :status,
        :due_date
      )
    end

    def render_unprocessable(resource)
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
