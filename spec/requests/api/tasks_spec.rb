require 'rails_helper'

RSpec.describe "Api::Tasks", type: :request do
  describe "GET /api/tasks" do
    context "when tasks exist" do
      before { create_list(:task, 3) }

      it "returns all tasks with status 200" do
        get "/api/tasks"

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["data"].size).to eq(3)
      end
    end

    context "filtering by status" do
      before do
        create(:task, status: "pending")
        create(:task, status: "doing")
        create(:task, status: "done")
      end

      it "returns only pending tasks" do
        get "/api/tasks?status=pending"

        json = JSON.parse(response.body)

        expect(json["data"].all? { |t| t["status"] == "pending" }).to be true
      end

      it "returns only done tasks" do
        get "/api/tasks?status=done"

        json = JSON.parse(response.body)

        expect(json["data"].all? { |t| t["status"] == "done" }).to be true
      end
    end

    context "filtering by due_date" do
      let(:date) { Date.new(2026, 2, 20) }

      before do
        create(:task, due_date: date)
        create(:task, due_date: Date.today)
      end

      it "returns tasks for the specified date" do
        get "/api/tasks?due_date=#{date}"

        json = JSON.parse(response.body)

        expect(json["data"].size).to eq(1)
        expect(json["data"].first["due_date"]).to eq(date.to_s)
      end
    end

    context "pagination" do
      before { create_list(:task, 15) }

      it "returns paginated results" do
        get "/api/tasks?page=2&per_page=5"

        json = JSON.parse(response.body)

        expect(json["data"].size).to eq(5)
        expect(json["page"]).to eq(2)
        expect(json["per_page"]).to eq(5)
      end
    end

    context "ordering by due_date" do
      before do
        create(:task, due_date: Date.new(2026, 2, 25))
        create(:task, due_date: Date.new(2026, 2, 20))
      end

      it "returns tasks ordered by due_date asc" do
        get "/api/tasks"

        json = JSON.parse(response.body)

        dates = json["data"].map { |t| t["due_date"] }.compact
        expect(dates).to eq(dates.sort)
      end
    end
  end

  # =========================
  # SHOW
  # =========================

  describe "GET /api/tasks/:id" do
    context "when task exists" do
      let(:task) { create(:task) }

      it "returns the task details" do
        get "/api/tasks/#{task.id}"

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json["data"]["id"]).to eq(task.id)
      end
    end

    context "when task does not exist" do
      it "returns a not found error" do
        get "/api/tasks/999999"

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(json).to include("errors")
        expect(json["errors"]).to include("Task not found")
      end
    end
  end

  # =========================
  # CREATE
  # =========================

  describe "POST /api/tasks" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          task: {
            title: "New task",
            status: "pending"
          }
        }
      end

      it "creates a task in the database" do
        expect {
          post "/api/tasks", params: valid_params
        }.to change(Task, :count).by(1)

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(json["data"]["title"]).to eq("New task")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          task: {
            title: "No",
            status: "invalid"
          }
        }
      end

      it "returns validation errors with proper structure" do
        post "/api/tasks", params: invalid_params

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json).to include("errors")
        expect(json["errors"]).to be_an(Array)
        expect(json["errors"]).not_to be_empty
      end
    end

    context "with title shorter than 3 characters" do
      it "returns validation error for title length" do
        post "/api/tasks", params: {
          task: {
            title: "ab",
            status: "pending"
          }
        }

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json["errors"]).to include(match(/title.*minimum is 3 characters/i))
      end
    end

    context "with invalid status value" do
      it "returns validation error for invalid status" do
        post "/api/tasks", params: {
          task: {
            title: "Valid task",
            status: "invalid_status"
          }
        }

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json["errors"]).to include(match(/Status is not included in the list/i))
      end
    end

    context "with missing title" do
      it "returns validation error when title is blank" do
        post "/api/tasks", params: {
          task: {
            title: "",
            status: "pending"
          }
        }

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json["errors"]).to include(match(/title.*can't be blank/i))
      end
    end

    context "with missing status" do
      it "creates task with default pending status" do
        post "/api/tasks", params: {
          task: {
            title: "Valid task"
          }
        }

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(json["data"]["status"]).to eq("pending")
      end
    end
  end

  # =========================
  # UPDATE
  # =========================

  describe "PATCH /api/tasks/:id" do
    let(:task) { create(:task, status: "pending") }

    context "with valid parameters" do
      it "updates the task" do
        patch "/api/tasks/#{task.id}", params: {
          task: { status: "done" }
        }

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(task.reload.status).to eq("done")
        expect(json["data"]["status"]).to eq("done")
      end
    end

    context "with invalid parameters" do
      it "returns validation errors without updating the task" do
        patch "/api/tasks/#{task.id}", params: {
          task: { status: "invalid" }
        }

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json).to include("errors")
        expect(task.reload.status).to eq("pending")
      end
    end
  end

  # =========================
  # DELETE
  # =========================

  describe "DELETE /api/tasks/:id" do
    context "when task exists" do
      let!(:task) { create(:task) }

      it "removes the task" do
        expect {
          delete "/api/tasks/#{task.id}"
        }.to change(Task, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when task does not exist" do
      it "returns not found without raising exception" do
        delete "/api/tasks/999999"

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(json).to include("errors")
expect(json["errors"]).to include("Task not found")

      end
    end
  end
end
