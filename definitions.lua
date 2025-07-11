---@meta

---@class MQTT_message
---@field id? string | nil                          Will be set by the broker
---@field payload? any                              Can be anything
---@field maxReads? number                          Reads until deletion. Optional
---@field sender number                             ComputerID of the message-sender
---@field target? number[]                          Table of targetID's. Optional. If set, only target computers will receive message (IF SUBSCRIBED to topic!)
---@field ttl? number                               Time to Live in Milliseconds. Default: 10 minutes, unless retain=true
---@field retain? boolean                           Will always send first, even if subscribed after message was send. Only one per Topic!
---@field timestamp? number                         will be set by the broker
---@field readBy? table<number,boolean>             will be managed by the broker

---@class MQTT_Topic
---@field messages MQTT_message[]
---@field subscribedClients MQTTBroker_ClientList   
---@field retainedMessage MQTT_message

---@class MQTT_TopicList
---@field topic {[string]: MQTT_Topic}              string => Topic

---@class MQTTBroker_Client
---@field timeoutDuration number                    Timeout in seconds - Overwritten in function "registerLastWillMessage"
---@field lastSeen number                           Updated in any request the Client inits
---@field subscribedToTopic string[]

---@class MQTTBroker_ClientList
---@field clients {[number]: MQTTBroker_Client}     number => ComputerID

---@type MQTT_message
local message;

---@type MQTT_messages
local messages;