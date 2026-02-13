module Api
  class TasksController < ApplicationController
    before_action :set_task, only: %i[show update destroy]

    # GET /tasks
    def index
      tasks = Task.all

      tasks = tasks.where(status: params[:status]) if params[:status].present?
      tasks = tasks.where(due_date: params[:due_date]) if params[:due_date].present?

      tasks = tasks.order(due_date: :asc)

      page = params[:page].to_i.positive? ? params[:page].to_i : 1
      per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 10

      total = tasks.count

      tasks = tasks.offset((page - 1) * per_page).limit(per_page)

      render json: {
        data: tasks,
        status: 200,
        total_records: total,
        per_page: per_page,
        page: page
      }
    end

    # GET /tasks/:id
    def show
      render json: { data: @task, status: 200 }
    end

    # POST /tasks
    def create
      task = Task.new(task_params)
      task.status ||= "pending"

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
