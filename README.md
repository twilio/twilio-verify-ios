# Twilio Verify Android

## Table of Contents

* [About](#About)
* [Definitions](#Definitions)
* [Errors](#Errors)

<a name='About'></a>

## About
Verify Push enables developers to implement secure push authentication without giving up privacy and control. This project provides a SDK to create and use verify push

<a name='Definitions'></a>	

## Definitions	
* `Service`: Scope the resources. It contains the configurations for each factor
* `Entity`: Represents anything that can be authenticated in a developer’s application. Like a User
* `Factor`: It is an established method for sending authentication Challenges. Like SMS, Phone Call, Push
* `Challenge`: It is a verification attempt sent to an Entity

<a name='Errors'></a>

## Errors
Types | Code | Description
---------- | ----------- | -----------
Network | 68001 | Exception while calling the API
Mapping | 68002 | Exception while mapping an entity
Storage | 68003 | Exception while storing/loading an entity
Input | 68004 | Exception while loading input
Key Storage | 68005 | Exception while storing/loading key pairs
Initialization | 68006 | Exception while initializing an object
Authentication Token | 68007 | Exception while generating token
