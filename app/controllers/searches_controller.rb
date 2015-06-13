class SearchesController < ApplicationController
  before_action :set_page, only: :show

  def show
    if params[:query] && params[:query].is_a?(String)
      if params[:es] == 'true'
        begin
          @gems = Rubygem.search(es_query(params)).page(@page).records
          @gems.size
        rescue Faraday::ConnectionFailed
          @fallback = true
          @gems = Rubygem.legacy_search(params[:query]).with_versions.paginate(page: @page)
        end
      else
        @gems = Rubygem.legacy_search(params[:query]).with_versions.paginate(page: @page)
      end
      @exact_match = Rubygem.name_is(params[:query]).with_versions.first

      redirect_to rubygem_path(@exact_match) if @gems == [@exact_match]
    end
  end

  private

  def es_query(params)
    {
      query: {
        term: {
          name: params[:query]
        }
      }
    }
  end
end
