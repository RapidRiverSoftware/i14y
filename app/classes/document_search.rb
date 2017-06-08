class DocumentSearch
  NO_HITS = { "hits" => { "total" => 0, "hits" => [] }}

  def initialize(options)
    # options: {:handles=>["agency_blogs"], :language=>:en, :query=>"99 problemz -site:agency.gov", :size=>10, :offset=>0}
    puts "initializing with options: #{options}"

    @options = options #.freeze
    puts "id in docSearch: #{@options.object_id}"

    @options[:offset] ||= 0
  end

  def search
    #options: {:handles=>["agency_blogs"], :language=>:en, :query=>"99 problemz -site:agency.gov", :size=>10, :offset=>0}
    i14y_search_results = execute_client_search
    #booo: {:handles=>["agency_blogs"], :language=>:en, :query=>"99 problemz ", :size=>10, :offset=>0}
    if i14y_search_results.total.zero? && i14y_search_results.suggestion.present?
      suggestion = i14y_search_results.suggestion
      @options[:query] += " #{suggestion['text']}"
      puts "options in suggestion: #{@options}"
      i14y_search_results = execute_client_search
      i14y_search_results.override_suggestion(suggestion) if i14y_search_results.total > 0
    end
    i14y_search_results
  rescue Exception => e
    Rails.logger.error "Problem in DocumentSearch#search(): #{e}
    #{e.backtrace}"
    DocumentSearchResults.new(NO_HITS)
  end

  private

  def execute_client_search
    #{:handles=>["agency_blogs"], :language=>:en, :query=>"99 problemz -site:agency.gov", :size=>10, :offset=>0}
    query = DocumentQuery.new(@options.except(:handles))
#booo {:handles=>["agency_blogs"], :language=>:en, :query=>"99 problemz ", :size=>10, :offset=>0}
    #puts "querying with options: #{@options.except(:handles)}"
=begin
 @options={:handles=>["agency_blogs"], :language=>:en, :query=>"99 problemz", :size=>10, :offset=>0},
 @site_filters=
  {:included_sites=>[],
   :excluded_sites=>[#<struct QueryParser::SiteFilter domain_name="agency.gov", url_path=nil>]}>
=end
    params = { index: document_indexes, body: query.body, from: @options[:offset], size: @options[:size] }
    
    result = Elasticsearch::Persistence.client.search(params)
    DocumentSearchResults.new(result, @options[:offset])
  end

  def document_indexes
    @options[:handles].map { |collection_handle| Document.index_namespace(collection_handle) }
  end

end
