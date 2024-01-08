class RcClient
  attr_accessor :results

  BASE_GRAPHQL_URL = 'https://www.royalcaribbean.com/graph?graph-app-version=green'
  HEADERS = {
    "Content-Type" => "application/json",
  }

  def initialize
    @results = []
  end

  def graphql_query(operation_name, variables, query)
    body = {
      operationName: operation_name,
      variables: variables,
      query: query
    }.to_json

    response = HTTPX.post(BASE_GRAPHQL_URL, headers: HEADERS, body: body)

    # Handle HTTP errors
    raise "Request failed with status #{response.status}" unless response.status == 200

    JSON.parse(response.body.to_s)
  end

  def get_sailings(ships = [], page_size = 100)
    @results = []
    operation_name = "cruiseSearch_Cruises"
    variables = {
      filters: "ship:#{ships.join(',')}",
      sort: { by: "RECOMMENDED"},
      pagination: { count: page_size, skip: 0}
    }
    query = """
      query cruiseSearch_Cruises($filters: String, $qualifiers: String, $sort: CruiseSearchSort, $pagination: CruiseSearchPagination) {
        cruiseSearch(
          filters: $filters,
          qualifiers: $qualifiers,
          sort: $sort,
          pagination: $pagination
        ) {
          results {
            cruises {
              id
              productViewLink
              lowestPriceSailing {
                bookingLink
                id
                lowestStateroomClassPrice {
                  price {
                    value
                    __typename
                  }
                  stateroomClass {
                    id
                    __typename
                  }
                  __typename
                }
                sailDate
                startDate
                endDate
                taxesAndFees {
                  value
                  __typename
                }
                taxesAndFeesIncluded
                __typename
              }
              masterSailing {
                itinerary {
                  name
                  code
                  media {
                    images {
                      path
                      __typename
                    }
                    __typename
                  }
                  days {
                    number
                    type
                    ports {
                      activity
                      arrivalTime
                      departureTime
                      port {
                        code
                        name
                        region
                        media {
                          images {
                            path
                            __typename
                          }
                          __typename
                        }
                        __typename
                      }
                      __typename
                    }
                    __typename
                  }
                  departurePort {
                    code
                    name
                    region
                    __typename
                  }
                  destination {
                    code
                    name
                    __typename
                  }
                  postTour {
                    days {
                      number
                      type
                      ports {
                        activity
                        arrivalTime
                        departureTime
                        port {
                          code
                          name
                          region
                          __typename
                        }
                        __typename
                      }
                      __typename
                    }
                    duration
                    __typename
                  }
                  preTour {
                    days {
                      number
                      type
                      ports {
                        activity
                        arrivalTime
                        departureTime
                        port {
                          code
                          name
                          region
                          __typename
                        }
                        __typename
                      }
                      __typename
                    }
                    duration
                    __typename
                  }
                  portSequence
                  sailingNights
                  ship {
                    code
                    name
                    stateroomClasses {
                      id
                      name
                      content {
                        amenities
                        area
                        code
                        maxCapacity
                        media {
                          images {
                            path
                            meta {
                              description
                              title
                              location
                              __typename
                            }
                            __typename
                          }
                          __typename
                        }
                        superCategory
                        __typename
                      }
                      __typename
                    }
                    media {
                      images {
                        path
                        __typename
                      }
                      __typename
                    }
                    __typename
                  }
                  portSequence
                  totalNights
                  type
                  __typename
                }
                __typename
              }
              sailings {
                bookingLink
                id
                itinerary {
                  code
                  __typename
                }
                sailDate
                startDate
                endDate
                taxesAndFees {
                  value
                  __typename
                }
                taxesAndFeesIncluded
                stateroomClassPricing {
                  price {
                    value
                    __typename
                  }
                  stateroomClass {
                    id
                    __typename
                  }
                  __typename
                }
                __typename
              }
              __typename
            }
            cruiseRecommendationId
            total
            __typename
          }
        }
      }
    """

    response = graphql_query(operation_name, variables, query)["data"]["cruiseSearch"]["results"]["cruises"].flatten
    @results += response
    while response.size == page_size
      sleep(0.5)
      variables[:pagination][:skip] += page_size
      response = graphql_query(operation_name, variables, query)["data"]["cruiseSearch"]["results"]["cruises"].flatten
      @results += response
    end
    @results = @results.map(&:deep_symbolize_keys)
  end

  def get_rooms(sailing)
    @results = []
    params =  {
      packageCode: sailing.sailing_code.split('_').first,
      stepSubtypeFlow: 'selectAndContinueSailDate', #important
      changeAccepted: true
    }

    Parallel.each(%w[INTERIOR OUTSIDE BALCONY DELUXE], in_threads: 4) do |stateroom_class|
      body = {
        acceptedChange: true,
        acceptedWipeState: false,
        continueConnectedStateroomFlow: false,
        sailDate: sailing.start_date.to_i * 1000,
        stateroom: stateroom_class,
      }.to_json

      puts "params = #{params.to_json}", "body = #{body.to_json}", ''
      response = HTTPX.
                  post('https://www.royalcaribbean.com/mcb/api/booking/step/sailDate',
                       params: params, headers: HEADERS, body: body)
      next if response.content_type.mime_type != 'application/json'

      data = JSON.parse(response.body.to_s).deep_symbolize_keys
      next if data.dig(:stepDetails, :itineraryChange).present? ||
              data.dig(:stepDetails, :stateroomCategoryGroups).blank?

      data[:stepDetails][:stateroomCategoryGroups].each do |stateroom_category_group|
        next if stateroom_category_group[:stateroomCategories].blank?

        stateroom_category_group[:stateroomCategories].each do |stateroom|
          stateroom[:cabinClass] = stateroom_class.downcase
          @results << stateroom
        end
      end
    end

    @results
  end
end
