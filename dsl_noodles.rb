 search do

   source ["title",
     "description",
     "content",
     "path",
     "created",
     "updated",
     "promote",
     "language",
     "tags",
     "changed",
     "updated_at"]
 
   sort do
      by :created, order: 'desc'
   end

   highlight fields: {
     title_en: { number_of_fragments: 0 },
     #etc
   }

   suggest ({
     text: 'historical',
     suggestion: {"phrase"=>
      {"field"=>"bigrams",
       "size"=>1,
       "highlight"=>{"pre_tag"=>"", "post_tag"=>""},
       "collate"=>{
         "query"=>{
           "multi_match"=>{"query"=>"{{suggestion}}", "type"=>"phrase", "fields"=>"*_en"}  }}  } }})

   query do
     filtered do
       query do

       end

       filter do
         bool do
           must term: { language: 'en' }
         end
       end
     end
   end
 end


{"_source"=>
  {"include"=>
    ["title",
     "description",
     "content",
     "path",
     "created",
     "updated",
     "promote",
     "language",
     "tags",
     "changed",
     "updated_at"]},
 "sort"=>{"created"=>{"order"=>"desc"}},


 "query"=>
  {"filtered"=>
    {"query"=>
      {"bool"=>
        {"must"=>
          {"bool"=>
            {"should"=>
              [{"common"=>
                 {"title_en"=>
                   {"query"=>"historical",
                    "cutoff_frequency"=>0.05,
                    "minimum_should_match"=>{"low_freq"=>"3<90%", "high_freq"=>"2<90%"}}}},
               {"common"=>
                 {"description_en"=>
                   {"query"=>"historical",
                    "cutoff_frequency"=>0.05,
                    "minimum_should_match"=>{"low_freq"=>"3<90%", "high_freq"=>"2<90%"}}}},
               {"common"=>
                 {"content_en"=>
                   {"query"=>"historical",
                    "cutoff_frequency"=>0.05,
                    "minimum_should_match"=>{"low_freq"=>"3<90%", "high_freq"=>"2<90%"}}}},
               {"match"=>{"basename"=>{"operator"=>"and", "query"=>"historical"}}},
               {"match"=>{"tags"=>{"operator"=>"and", "query"=>"historical"}}}]}},
         "should"=>
          [{"match"=>{"bigrams"=>{"operator"=>"and", "query"=>"historical"}}},
           {"multi_match"=>{"query"=>"historical", "fields"=>["title", "description", "content"]}}]}},
     "filter"=>{"bool"=>{"must"=>[{"term"=>{"language"=>"en"}}, {"bool"=>{"should"=>[]}}]}}}},

 "highlight"=>
  {"pre_tags"=>[""],
   "post_tags"=>[""],
   "fields"=>
    {"title_en"=>{"number_of_fragments"=>0},
     "description_en"=>{"fragment_size"=>75, "number_of_fragments"=>2},
     "content_en"=>{"fragment_size"=>75, "number_of_fragments"=>2}}},

 "suggest"=>
  {"text"=>"historical",
   "suggestion"=>
    {"phrase"=>
      {"field"=>"bigrams",
       "size"=>1,
       "highlight"=>{"pre_tag"=>"", "post_tag"=>""},
       "collate"=>{"query"=>{"multi_match"=>{"query"=>"{{suggestion}}", "type"=>"phrase", "fields"=>"*_en"}}}}}}}
