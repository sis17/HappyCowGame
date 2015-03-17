class IssuesController < ApplicationController
  def index
    @issues = Issue.all
    render json: @issues.as_json
  end

  def show
    @issues = Issue.find(params[:id])
    render json: @issue.as_json
  end

  def update
    @issue = Issue.find(params[:id])
    @issue.update(params.require(:issue).permit(:status, :resolution))
  end

  def create
    if params[:user_id] and params[:title] and params[:description]
      @issue = Issue.new
      @issue.title = params[:title]
      @issue.description = params[:description]
      @issue.user_id = params[:user_id]
      @issue.status = 1
      @issue.save
      render json: {
        success: true,
        message: {title: 'Issue Reported', text: 'The issue has been reported.', type: 'success'}
      } and return
    end
    render json: {
      success: false,
      message: {title: 'Not enough details', text: 'Please include a title and description.', type: 'warning'}
    } and return
  end

  def destroy

  end

end
