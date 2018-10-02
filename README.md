# Banking Account [![Build Status](https://travis-ci.org/Seralto/bank-account-api.svg?branch=master)](https://travis-ci.org/Seralto/bank-account-api)
This project is a RESTFul API that implements simple banking features.
Each client has an account and a client can transfer money to other accounts and request his current balance.
The system only handles one type of currency that is brazilian Real (BRL).

## Demo
You can see a live demo of this API and test the endpoints bellow [here](https://bank-account-api.herokuapp.com).

## Dependencies
The project has the following dependencies:

* Ruby 2.5.1
* Rails 5.2.1

## Setup
In order to run the program, follow the steps:

1. Install the project dependencies above and run the following commands.
2. `$ git clone https://github.com/Seralto/bank-account-api`
3. `$ cd bank-account-api`
4. `$ bundle install`
5. `$ rails db:setup`

## Running
1. `$ rails server`
2. Go to [http://localhost:3000](http://localhost:3000) in your browser.

## API Usage
Bellow you can see the main usage of the project resources.

### Creating an Client

```
POST /clients
```

**Input**:

Attribute	|	Type	|	Description
----	|	----	|	----
`name`	|	`string`	|	Client name **(required)**
`email`	|	`string`	|	Client email **(required)**
`password`	|	`string`	|	Password **(required)**
`password_confirmation`	|	`string`	|	Password confirmation **(required)**

**Example**:

```json
{
  "client": {
    "name": "John Doe",
    "email": "john.doe@mail.com",
    "password": "top-secret",
    "password_confirmation": "top-secret"
  }
}
```

**Response**:

```
Status: 201 Created
```
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john.doe@mail.com",
  "created_at": "2018-10-01T19:34:22.520Z",
  "account": null
}
```

### Authenticating
The project uses the [JSON Web Token (JWT)](https://github.com/jwt/ruby-jwt) gem to perform authentication.

After getting a **token**, you should send it in every request header, except on client creation **"POST /clients"**:

```
Authorization: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1Mzg1MTIxNTF9.kimM1jrvsEozyzRHlskDugikZWk0l_W8yU7yNzRwZ1I
```

```
POST /authenticate
```

**Input**:

Attribute	|	Type	|	Description
----	|	----	|	----
`email`	|	`string`	|	Client email **(required)**
`password`	|	`string`	|	Password **(required)**

**Example**:

```json
{
  "email": "john.doe@mail.com",
  "password": "top-secret"
}
```

**Response**:

```
Status: 200 OK
```
```json
{
  "auth_token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyLCJleHAiOjE1Mzg1MTIzNTN9.d6ej60b8BleH15-8Dpy57uabyK9JEQFFeqbK0RXDHO8"
}
```

### Creating an User Account

```
POST /accounts
```

**Input**:

Attribute	|	Type	|	Description
----	|	----	|	----
`client_id`	|	`string`	|	Client ID to be associated **(required)**
`balance`	|	`number`	|	Initial balance **(required)**

**Example**:

```json
{
  "account": {
    "client_id": "1",
    "balance": 1000
  }
}
```

**Response**:

```
Status: 201 Created
```
```json
{
  "id": 1,
  "client_id": 1,
  "balance": "R$ 1.000,00",
  "created_at": "2018-10-01T20:45:22.001Z"
}
```

### Getting the Client Account Balance

```
GET /clients/:client_id/balance
```

**Successful Response**:

```
Status: 200 OK
```
```json
{
  "current_balance": "R$ 1.000,00"
}
```

**Account does not exist Response**:

```
Status: 404 Not Found
```
```json
{
  "error": "Couldn't find Client with 'id'=1"
}
```

### Transfering Money

The system only allows money transfer from the authenticated Client (source_account).

```
POST /clients/:client_id/transfer_money
```

**Input**:

Attribute	|	Type	|	Description
----	|	----	|	----
`destination_account_id`	|	`string`	|	Destination Account ID **(required)**
`amount`	|	`number`	|	Amount to be transfered **(required)**

**Example**:

```json
{
  "destination_account_id": 2,
  "amount": 100
}
```

**Successful Response**:

```
Status: 200 OK
```
```json
{
  "amount_transferred": "R$ 100,00",
  "current_balance": "R$ 900,00"
}
```

**Not enough money Response**:
```
Status: 400 Bad Request
```
```json
{
  "error": "Not enough money"
}
```

**Diferent Client transfer attempt Response**:
```
Status: 403 Forbidden
```
```json
{
  "error": "Transfer not allowed"
}
```

### Testing
Run all tests with the command:

```shell
$ bundle exec rspec
```

Or run a specific file:

```shell
$ bundle exec rspec spec/controllers/clients_controller_spec.rb
```

Or run a specific test:

```shell
$ bundle exec rspec spec/controllers/clients_controller_spec.rb:166
```