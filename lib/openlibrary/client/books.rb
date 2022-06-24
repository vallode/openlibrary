module Openlibrary
  module Books
    # Find books in Open Library by OLID, ISBN, LCCN, or OCLC
    #
    def book(olid)
      data = request("/books/#{olid}")
      Hashie::Mash.new(data)
    end

    def book_by_isbn(isbn)
      if isbn.length != 10 && isbn.length != 13
        raise ArgumentError, "ISBN must be 10 or 13 characters."
      end

      request("/isbn/#{isbn}")
    end

    def book_by_lccn(lccn)
      metadata = get_metadata("lccn", lccn)

      if metadata
        olid = extract_olid_from_url(metadata["info_url"], "books")
        book(olid)
      end
    end

    def book_by_oclc(oclc)
      metadata = get_metadata("oclc", oclc)

      if metadata
        olid = extract_olid_from_url(metadata["info_url"], "books")
        book(olid)
      end
    end

    def get_metadata(key, value)
      _key = "#{key}:#{value}"
      data = request("/api/books.json?bibkeys=#{_key}", {})

      if data.include? _key
        data[_key]
      end
    end

    def extract_olid_from_url(url, url_type)
      ol_url_pattern = /\/#{Regexp.quote(url_type)}\/([0-9a-zA-Z]+)/

      ol_url_pattern.match(url) do |m|
        m.captures[0]
      end
    end
  end
end
