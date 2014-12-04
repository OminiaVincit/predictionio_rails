# Yelpio API
Yelpio API is a *short api* service using the YELP data set and prediction IO system.

# Data schema

## App model

	create_table "apps", force: true do |t|
    	t.string   "api_key"
    	t.string   "name"
    	t.datetime "created_at"
    	t.datetime "updated_at"
    	t.string   "api_rpm"
	end
  
## User model

	create_table "users", force: true do |t|
    	t.string   "yelp_user_id"
    	t.string   "name"
    	t.float    "average_stars"
    	t.datetime "created_at"
    	t.datetime "updated_at"
    	t.integer  "reviews_count", default: 0, null: false
	end
  
## Business model

	create_table "businesses", force: true do |t|
    	t.string   "yelp_business_id"
    	t.string   "name"
    	t.string   "full_address"
    	t.string   "city"
    	t.string   "state"
    	t.float    "stars"
    	t.datetime "created_at"
    	t.datetime "updated_at"
    	t.float    "longitude"
    	t.float    "latitude"
    	t.text     "categories"
	end

## Review model

	create_table "reviews", force: true do |t|
    	t.string   "yelp_business_id"
    	t.string   "yelp_user_id"
    	t.float    "stars"
    	t.text     "content"
    	t.integer  "user_id"
    	t.integer  "business_id"
    	t.datetime "created_at"
    	t.datetime "updated_at"
	end
  
# Group Users
Users related resources of the **Yelpio API**

## Users Collection [http://yelpio.hongo.wide.ad.jp/api/v1/users]
### List of params
+ sort  *{id(default), name, reviews_count, created_at, updated_at}*
+ order *{ASC, DESC, default = DESC}*
+ page {default=1}, page_size {default=25}

### List all users, default for *page = 1, page_size = 25, DESC sorted id* [GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/users"
+ Response 200 (application/json)

        [{"id":43884,"yelp_user_id":"TestForYelpUserIdAgain10","name":"Jimi2","average_stars":2.70833333333334,"created_at":"2014-12-03T07:59:12.437Z","updated_at":"2014-12-04T07:50:35.665Z","reviews_count":8
        }, {
          "id":43883,"yelp_user_id":"TestForYelpUserIdAgain9","name":"Test for name2","average_stars":null,"created_at":"2014-12-03T07:53:51.374Z","updated_at":"2014-12-03T07:57:45.212Z","reviews_count":0
        }, {
          "id":43882,"yelp_user_id":"TestForYelpUserIdAgain8","name":"Test for name","average_stars":null,"created_at":"2014-12-03T07:37:43.365Z","updated_at":"2014-12-03T07:37:43.365Z","reviews_count":0
        },...]

### List n (page_size=n) latest users [GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/users?page=1&page_size=3"
+ Response 200 (application/json)]

        [{"id":43884,"yelp_user_id":"TestForYelpUserIdAgain10","name":"Jimi2","average_stars":2.70833333333334,"created_at":"2014-12-03T07:59:12.437Z","updated_at":"2014-12-04T07:50:35.665Z","reviews_count":8
        }, {
          "id":43883,"yelp_user_id":"TestForYelpUserIdAgain9","name":"Test for name2","average_stars":null,"created_at":"2014-12-03T07:53:51.374Z","updated_at":"2014-12-03T07:57:45.212Z","reviews_count":0
        }, {
          "id":43882,"yelp_user_id":"TestForYelpUserIdAgain8","name":"Test for name","average_stars":null,"created_at":"2014-12-03T07:37:43.365Z","updated_at":"2014-12-03T07:37:43.365Z","reviews_count":0
        }]
        
### List all users sorted by name [GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/users?sort=name&page=1&page_size=10"
+ Response 200 (application/json)

        [{"id":35225,"yelp_user_id":"YM-Ynn2LCBJHP6p1l4P6xQ","name":"Zuleika","average_stars":3.86,"created_at":"2014-11-29T04:21:39.573Z","updated_at":"2014-11-29T04:21:39.573Z","reviews_count":1
        }, {
          "id":25498,"yelp_user_id":"-_GY1HTGxxE0ZyQ6cw0KSQ","name":"Zsazsa","average_stars":2.33,"created_at":"2014-11-29T04:18:46.829Z","updated_at":"2014-11-29T04:18:46.829Z","reviews_count":1
        }, {
          "id":26798,"yelp_user_id":"FueQBxW27QIVkg7Pbf_Tuw","name":"Zoya","average_stars":3.54,"created_at":"2014-11-29T04:19:09.916Z","updated_at":"2014-11-29T04:19:09.916Z","reviews_count":4
        },...]

### List all users sorted by reviews_count [GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/users?sort=reviews_count&page=1&page_size=10"
+ Response 200 (application/json)

        [{"id":6279,"yelp_user_id":"fczQCSmaWF78toLEmb0Zsw","name":"Gabi","average_stars":4.0,"created_at":"2014-11-29T04:13:06.625Z","updated_at":"2014-11-29T04:13:06.625Z","reviews_count":588
          }, {
          "id":9722,"yelp_user_id":"90a6z--_CUrl84aCzZyPsg","name":"Michael","average_stars":3.99,"created_at":"2014-11-29T04:14:07.389Z","updated_at":"2014-11-29T04:14:07.389Z","reviews_count":506
          }, {
          "id":6907,"yelp_user_id":"4ozupHULqGyO42s3zNUzOQ","name":"Lindsey","average_stars":4.29,"created_at":"2014-11-29T04:13:17.723Z","updated_at":"2014-11-29T04:13:17.723Z","reviews_count":442
        },...]
        
### Create a user [POST]
+ curl -H "Content-Type: application/json" -X POST --data "@user.json" http://yelpio.hongo.wide.ad.jp/api/v1/users
+ Request (@user.json) (application/json)

        [{"user":{"name":"Ammy", "yelp_user_id":"AppTestForPostYelpUserId"}}]

+ Response 201 (application/json)

        [{"id":43885,"yelp_user_id":"AppTestForPostYelpUserId","name":"Ammy","average_stars":null,"created_at":"2014-12-04T09:30:53.555Z","updated_at":"2014-12-04T09:30:53.555Z","reviews_count":0}]
       
+ Response null JSON string if the user already existed in the database


## User [/users/{id}&{yelp_user_id}]
A single user object with all its details
### List of params 
+ id (number, `1`) ... Numeric `id` of the user to perform action.
+ yelp_user_id (string) ... Previous defined user_id in YELP_TRAINING_DATA_ 
+ method (string, 'predict')... Get the predicted result from  PIO event server
+ num (number, default=10)... Number of the predicted result from PIO event server

### Retrieve user from id or yelp_user_id [GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/users/6279"
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/users.json?id=6279"
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/users.json?yelp_user_id=fczQCSmaWF78toLEmb0Zsw"

+ Response 200 (application/json)

		[{"id":6279,"yelp_user_id":"fczQCSmaWF78toLEmb0Zsw","name":"Gabi","average_stars":4.0,"created_at":"2014-11-29T04:13:06.625Z","updated_at":"2014-11-29T04:13:06.625Z","reviews_count":588}]

+ Response null JSON string if the user not found

### Update user information [PUT]
+ curl -H "Content-Type: application/json" -X PUT --data "@user.json" http://yelpio.hongo.wide.ad.jp/api/v1/users/1/
+ Request (@user.json) (application/json)

        [{"user":{"name":"Jessica", "yelp_user_id":"AppTestForPostYelpUserId"}}]

+ Response 201 (application/json)

        [{"id":43885,"yelp_user_id":"AppTestForPostYelpUserId","name":"Jessica","average_stars":null,"created_at":"2014-12-04T09:30:53.555Z","updated_at":"2014-12-04T09:33:32.789Z","reviews_count":0}]

+ Response null JSON string if the user doesn't exist in the database

### Retrieve n (num = n) predicted result (restaurant information) of a user[GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/users/6279?method=predict&num=1"
+ Response 200 (application/json)

		[{"business":{"id":4408,"yelp_business_id":"Nwh2N0k-u4q_dV2VLY4Fgw","name":"Cafe At Sun City","full_address":"3385 N Hunt Hwy\nSte 121\nFlorence, AZ 85132","city":"Florence","state":"AZ","stars":2.5,"created_at":"2014-11-29T06:23:27.377Z","updated_at":"2014-12-02T07:00:15.921Z","longitude":-111.484426,"latitude":33.06293,"categories":["Cafes","Restaurants"]},"score":5.0}]
	
+ Response null JSON string if the user doesn't exist in the database

# Group Businesses
Businesses related resources of the **Yelpio API**

## Businesses Collection [http://yelpio.hongo.wide.ad.jp/api/v1/businesses]
### List of params
+ sort  *{value: "id", "name", "created_at", "updated_at", default = "id"}*
+ order *{value: "ASC", "DESC", default = "DESC"}*
+ page *{value: number, default=1}*, page_size *{value: number, default=25}*
+ cagegorize *{value: string, ex: "restaurant"}
+ location *{value: string, ex: "Scottsdale,AZ"}
+ radius *{value: float number in km, default=10}
+ longitude *{value: float number}*
+ latitude *{value: float number}*

### List all businesses, default for *page = 1, page_size = 25, DESC sorted id* [GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/businesses"
+ Response 200 (application/json)

### List all businesses sorted by business name [GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/businesses?sort=name&page=1&page_size=10"
+ Response 200 (application/json)

### List all businesses in categorize [GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/businesses.json?categorize=restaurant&page=1&page_size=10"
+ Response 200 (application/json)

### List all nearest businesses near a location (or coordinate) with radius in km [GET]
+ By location:  curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/businesses?categorize=restaurant&radius=5&location=Scottsdale,AZ"

+ By coordinate: curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/businesses?categorize=restaurant&radius=5&longitude=-111.92605&latitude=33.494"

+ Top 10 nearest restaurant:  curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/businesses?categorize=restaurant&radius=5&location=Scottsdale,AZ&page_size=10"


## Business [/businesses/{id}&{yelp_business_id}]
A single user object with all its details
### List of params
+ id (number, `1`) ... Numeric `id` of the user to perform action.
+ yelp_business_id (string) ... Previous defined business_id in YELP_TRAINING_DATA_ 

### Retrieve business from id or yelp_user_id [GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/businesses/11133"
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/businesses?id=11133"
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/businesses?yelp_business_id=Zdi-Mrwk_JNnhopAAbxRcQ"

+ Response 200 (application/json)
+ Response null JSON string if the business not found

# Group Reviews
Businesses related resources of the **Yelpio API**

## Reviews Collection [http://yelpio.hongo.wide.ad.jp/api/v1/reviews]
### List of params
+ sort  *{value: "id", "user_id", "business_id", "yelp_user_id", "yelp_business_id", "stars", "created_at", "updated_at", default = "id"}*
+ order *{value: "ASC", "DESC", default = "DESC"}*
+ page *{value: number, default=1}*, page_size *{value: number, default=25}*

### List all reviews, default for *page = 1, page_size = 25, DESC sorted id* [GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/reviews.json"
+ Response 200 (application/json)

### List all reviews sorted by business id [GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/reviews.json?sort=business_id&page=1&page_size=10"
+ Response 200 (application/json)

### Create new review [POST]
+ Require parameter: yelp_business_id, yelp_user_id, stars
+ curl -H "Content-Type: application/json" -X POST --data "@review.json" http://yelpio.hongo.wide.ad.jp/api/v1/reviews
+ Request (@review.json) (application/json)

		{"review":{"yelp_business_id":"6yVe_iet5qD7SzVMhRYYog", "yelp_user_id":"TestForYelpUserIdAgain10", "stars":4.0, "content":"I want to eat at here again"}}

+ Response 201 (application/json)

		{"review":{"yelp_business_id":"6yVe_iet5qD7SzVMhRYYog", "yelp_user_id":"TestForYelpUserIdAgain10", "stars":4.0, "content":"I want to eat at here again"}}
       
+ Response null JSON string if the user already existed in the database

## Reviews [/reviews/{id}]
A single user object with all its details
### List of params
+ id (number, `1`) ... Numeric `id` of the user to perform action.
+ business_id
+ yelp_business_id (string) ... Previous defined business_id in YELP_TRAINING_DATA_ 
+ user_id
+ yelp_user_id

### Retrieve reviews from reviews_id, yelp_business_id or yelp_user_id [GET]
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/reviews/11133"
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/reviews.json?yelp_business_id=rncjoVoEFUJGCUoC1JgnUA"
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/reviews.json?business_id=1234"
+ curl -H "Accept: application/json" "http://yelpio.hongo.wide.ad.jp/api/v1/reviews.json?yelp_user_id=PahwPVfd6BkDyO8KCFEoWw&yelp_business_id=3jqOv6re-xPYOg7srmi7tg"

+ Response 200 (application/json)


