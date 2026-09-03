CREATE OR REPLACE TABLE nested_data (
    record_id NUMBER,
    data VARIANT
);

INSERT INTO nested_data (record_id, data)
SELECT
    1,
    PARSE_JSON('{
      "customer": {
        "profile": {
          "personal": {
            "name": {
              "first": "Abigail",
              "last": "O''Brien"
            },
            "contact": {
              "emails": [
                {
                  "type": "personal",
                  "addresses": [
                    {
                      "email": "abigail@gmail.com",
                      "verified": true
                    },
                    {
                      "email": "abigail.work@gmail.com",
                      "verified": true
                    }
                  ]
                },
                {
                  "type": "backup",
                  "addresses": [
                    {
                      "email": "abigail.backup@gmail.com",
                      "verified": false
                    }
                  ]
                }
              ]
            }
          }
        },
        "orders": [
          {
            "order_id": "ORD-1001",
            "items": [
              {
                "product": {
                  "product_id": "P-101",
                  "name": "Laptop"
                },
                "quantity": 1,
                "reviews": [
                  {
                    "review_id": "R-1",
                    "rating": 5,
                    "comments": [
                      {
                        "type": "positive",
                        "text": "Excellent laptop"
                      },
                      {
                        "type": "delivery",
                        "text": "Fast delivery"
                      }
                    ]
                  }
                ]
              },
              {
                "product": {
                  "product_id": "P-102",
                  "name": "Mouse"
                },
                "quantity": 2,
                "reviews": [
                  {
                    "review_id": "R-2",
                    "rating": 4,
                    "comments": [
                      {
                        "type": "positive",
                        "text": "Good mouse"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    }')

UNION ALL

SELECT
    2,
    PARSE_JSON('{
      "customer": {
        "profile": {
          "personal": {
            "name": {
              "first": "Daniel",
              "last": "Smith"
            },
            "contact": {
              "emails": [
                {
                  "type": "personal",
                  "addresses": [
                    {
                      "email": "daniel@gmail.com",
                      "verified": true
                    }
                  ]
                }
              ]
            }
          }
        },
        "orders": [
          {
            "order_id": "ORD-2001",
            "items": [
              {
                "product": {
                  "product_id": "P-201",
                  "name": "Keyboard"
                },
                "quantity": 1,
                "reviews": [
                  {
                    "review_id": "R-3",
                    "rating": 5,
                    "comments": [
                      {
                        "type": "positive",
                        "text": "Great keyboard"
                      },
                      {
                        "type": "quality",
                        "text": "Very durable"
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            "order_id": "ORD-2002",
            "items": [
              {
                "product": {
                  "product_id": "P-202",
                  "name": "Monitor"
                },
                "quantity": 2,
                "reviews": [
                  {
                    "review_id": "R-4",
                    "rating": 4,
                    "comments": [
                      {
                        "type": "positive",
                        "text": "Nice display"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    }');