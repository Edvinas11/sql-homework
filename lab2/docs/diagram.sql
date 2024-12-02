Table clients {
  id integer [primary key]
  
  name text
  personal_code text
  lastname text
  birth_date date
  address_street text
  address_city text
  address_zip_code text
}

Table cars {
  id integer [primary key]
  
  brand text
  vin text
  model text
  type text
  price_per_day decimal(10, 2)
}

Table orders {
  order_nr integer [primary key]
  
  client_id integer [not null, ref: > clients.id]
  order_date_start date [not null]
  order_date_end date [not null]
  price decimal(10, 2)
  status text
  payment_method text
}

Table order_cars {
  order_nr integer [ref: > orders.order_nr]
  car_id integer [ref: > cars.id]
  
  total_price decimal(10, 2)
}

