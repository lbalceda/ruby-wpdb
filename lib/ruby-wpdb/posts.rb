Sequel.inflections do |inflect|
  # Unless we tell Sequel otherwise, it will try to inflect the singular
  # of "postmeta" using the "data" -> "datum" rule, leaving us with the
  # bizarre "postmetum".
  inflect.uncountable 'postmeta'
end

module WPDB
  class Post < Sequel::Model(:"#{WPDB.prefix}posts")
    one_to_many :children, :key => :post_parent, :class => self
    one_to_many :postmeta, :class => :'WPDB::PostMeta'
    many_to_one :author, :key => :post_author, :class => :'WPDB::User'
    one_to_many :comments, :key => :comment_post_ID, :class => :'WPDB::Comment'

    one_to_many :termrelationships, :key => :object_id, :key_method => :obj_id, :class => 'WPDB::TermRelationship'
    many_to_many :termtaxonomy, :left_key => :object_id, :right_key => :term_taxonomy_id, :join_table => :"#{WPDB.prefix}term_relationships", :class => 'WPDB::TermTaxonomy'

    def add_term(term, taxonomy)
      if term.respond_to?(:term_id)
        term_id = term.term_id
      else
        term_id = term.to_i
      end

      term_taxonomy = WPDB::TermTaxonomy.where(:term_id => term_id, :taxonomy => taxonomy).first
      unless term_taxonomy
        term_taxonomy = WPDB::TermTaxonomy.create(:term_id => term_id, :taxonomy => taxonomy)
      end

      add_termtaxonomy(term_taxonomy)
    end
  end

  class PostMeta < Sequel::Model(:"#{WPDB.prefix}postmeta")
  end
end
