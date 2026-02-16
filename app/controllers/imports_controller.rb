# Handles the upload step (Phase 1).
# Parses the CSV immediately and creates an ImportSession,
# then redirects to the preview screen. Nothing is written to
# properties or units at this stage.
class ImportsController < ApplicationController
  def new
    # Upload form
  end

  def create
    file = params[:file]

    unless file.present?
      return redirect_to new_import_path, alert: "Please select a CSV file to upload."
    end

    
    unless File.extname(file.original_filename).downcase == ".csv"
      return redirect_to new_import_path, alert: "Only .csv files are accepted."
    end

    parser = CsvParser.new(file: file)

    unless parser.valid_header?
      return redirect_to new_import_path,
                         alert: "Invalid CSV headers — #{parser.header_error}"
    end

    rows    = parser.rows
    session = ImportSessionBuilder.build(rows: rows, filename: file.original_filename)

    redirect_to import_session_path(session),
                notice: "File parsed. Please review the import below before confirming."
  end
end
