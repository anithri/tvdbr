module Tvdb
  # { "ContentRating"=>"TV-MA", "Status"=>"Continuing", "Airs_Time"=>"9:00 PM", "FirstAired"=>"2006-10-01", "Runtime"=>"60",
  #   "banner"=>"graphical/79349-g7.jpg", "poster"=>"posters/79349-2.jpg", "id"=>"79349", "Genre"=>"|Action and Adventure|Drama|",
  #   "Network"=>"Showtime", "Overview"=>"...", "addedBy"=>nil, "lastupdated"=>"1295047217", "IMDB_ID"=>"tt0773262",
  #   "Language"=>"en", "SeriesName"=>"Dexter", "Rating"=>"9.3", "fanart"=>"fanart/original/79349-16.jpg",
  #   "Actors"=>"|Michael C. Hall|Julie Benz|", "Airs_DayOfWeek"=>"Sunday",
  #   "zap2it_id"=>"SH859795", "RatingCount"=>"678", "SeriesID"=>"62683" }
  class Series < DataSet
    alias_property :series_name, :title
    alias_property :overview, :synopsis
    alias_property :actors, :starring
    alias_property :genre, :categories
    alias_property :first_aired, :release_date
    listify :genre, :actors
    dateify :first_aired
    absolutize :fanart, :poster, :banner

    def episodes
      episode_data = self.parent.find_series_by_id(self.id, :all => true)
      return [] unless episode_data && episode_data['Episode']
      episode_data['Episode'].map { |e| Episode.new(self, e) if e && e.is_a?(Hash) }.compact
    end

    # Returns true if the series matches the given actors
    # actors = ['x', 'y', 'z']
    # series.actor_match?(actors) => true
    def actor_match?(actors)
      expected_actors   = actors.map      { |a| a.downcase.strip.gsub(/[\.\-\s\']/, '') }
      normalized_actors = self.actors.map { |a| a.downcase.strip.gsub(/[\.\-\s\']/, '') }
      # puts "1: #{self.inspect} - #{self.title} - #{normalized_actors.inspect} - #{expected_actors.inspect}"
      # puts "2: " + (normalized_actors & expected_actors).inspect
      normalized_actors.is_a?(Array) && expected_actors.is_a?(Array) &&
      (normalized_actors & expected_actors).size > 1
    end
  end

  # {:combined_episodenumber=>"14", :imdb_id=>nil, :episode_number=>"14", :absolute_number=>nil, :first_aired=>"2010-05-04",
  #  :dvd_episodenumber=>nil, :episode_name=>"The Candidate", :rating=>"7.9", :filename=>"episodes/73739/1685171.jpg", :director=>"Jack Bender",
  #  :seasonid=>"66871", :writer=>"|Elizabeth Sarnoff|Jim Galasso|", :dvd_chapter=>nil, :production_code=>nil, :combined_season=>"6", :season_number=>"6",
  #  :dvd_season=>nil, :language=>"en", :dvd_discid=>nil, :lastupdated=>"1277153526",
  #  :overview=>"...", :id=>"1685171", :ep_img_flag=>"2", :rating_count=>"187", :seriesid=>"73739", :guest_stars=>nil}
  class Episode < DataSet
    alias_property :episode_name, :name
    alias_property :episode_number, :episode_num
    alias_property :season_number, :season_num
    alias_property :overview, :description
    alias_property :first_aired, :original_air_date
    dateify :first_aired
    listify :writer
    absolutize :filename
  end
end
