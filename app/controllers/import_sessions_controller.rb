# Handles the preview and confirm steps (Phases 2 & 3).
class ImportSessionsController < ApplicationController
  before_action :set_session

  # GET /import_sessions/:id
  # Preview screen — shows annotated rows, summary banner, confirm button
  def show
    # @import_session is set by before_action
  end

  # DELETE /import_sessions/:id/rows/:row_index
  # Dismiss a single row from the import without touching the CSV.
  # Responds to Turbo Stream so the row disappears without a full page reload.
  def dismiss_row
    index = params[:row_index].to_i

    unless @import_session.pending?
      return redirect_to import_session_path(@import_session),
                         alert: "This import has already been #{@import_session.status}."
    end

    dismissed = (@import_session.dismissed_rows + [index.to_i]).uniq
    @import_session.update!(dismissed_rows: dismissed)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("row_#{index}"),
          turbo_stream.replace("summary_banner",
                               partial: "import_sessions/summary_banner",
                               locals: { session: @import_session.reload }),
          turbo_stream.replace("confirm_section",
                               partial: "import_sessions/confirm_section",
                               locals: { session: @import_session })
        ]
      end
      format.html { redirect_to import_session_path(@import_session) }
    end
  end

  # POST /import_sessions/:id/confirm
  # Commits all active (non-dismissed) rows to the database inside a transaction.
  def confirm
  Rails.logger.debug "status: #{@import_session.status}"
  Rails.logger.debug "active_rows: #{@import_session.active_rows.count}"
  Rails.logger.debug "blocking_rows: #{@import_session.blocking_rows.count}"
  Rails.logger.debug "confirmable: #{@import_session.confirmable?}"
    unless @import_session.confirmable?
      return redirect_to import_session_path(@import_session),
                         alert: "Import cannot be confirmed — resolve or dismiss all errors first."
    end

    result = PropertyCommitter.commit(@import_session)

    if result.success?
      redirect_to import_session_path(@import_session),
                  notice: "Import complete. #{result.created_count} created, #{result.updated_count} updated."
    else
      redirect_to import_session_path(@import_session),
                  alert: "Import failed and was rolled back. #{result.error_message}"
    end
  end

  private

  def set_session
    @import_session = ImportSession.find(params[:id])
  end
end
