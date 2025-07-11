local scm = require("scm")
local class = scm:load("ccClass")

---@class MQTTBroker
---@field clientList MQTTBroker_ClientList
---@field topicList MQTT_TopicList
---@field validator nil | fun(topic, message): boolean, (nil | string)
---@field defaultTimeout number 5 minutes
---@field private messageIndex {[number]: MQTT_message}
local MQTTBroker = class(function (a)

    a.defaultTimeOut = 300 * 1000 -- 5 minutes

    a.clientList = {}

    a.validator = nil

    a.messageList = {}
    a.topicList = {}

    a.messageIndex = {}

end) --[[@as MQTTBroker]]

local ERRORText = {
    ["validate_MessageWrongType"] = "Message is not of type table! It is type %s",
    ["validate_MissingSender"] = "Sender_ID is Missing",
}

---@private
---@return MQTT_Topic
function MQTTBroker:createEmptyTopic()
    return {messages = {}, subscribedClients = {}, retainedMessage = nil}
end

---@param id any
---@return MQTT_message | nil
function MQTTBroker:getMessageByID(id)
    return self.messageIndex[id]
end



---@param topic string
---@param message MQTT_message
---@return boolean
---@return string | nil
function MQTTBroker:validateMessage(topic, message)
    if type(message) ~= "table" then
        return false, string.format(ERRORText["validate_MessageWrongType"], type(message))
    end
    if not message.sender or type(message.sender) ~= "number" then
        return false, ERRORText["validate_MissingSender"]
    end
    if not MQTTBroker.validator then return true end
    return MQTTBroker.validator(topic, message.payload)
end

---@param topic string
---@param message MQTT_message
---@return boolean success
---@return string | nil idOrErrorReason
function MQTTBroker:publish(topic, message)

    local ok, err = self:validateMessage(topic, message) 
    if not ok then
        return false, err
    end

    -- add suffix, as more then one message "could"'ve come in per timestamp
    local suffix = 0
    local isDublicate = true
    local currentTime = string.format(math.floor(os.time()))
    while isDublicate do
        if self:getMessageByID(currentTime .. suffix) then
            suffix = suffix + 1
            isDublicate = true
        else
            isDublicate = false
        end
    end
    message.id = currentTime .. suffix

    -- if retain is set, no ttl will be set (from the broker anyway)
    if not message.retain and not message.ttl then
        message.ttl = self.defaultTimeout
    end

    -- adding message to the message- and indexList    
    if self.topicList[topic] == nil then
        self.topicList[topic] = self:createEmptyTopic()
    end
    
    if message.retain then
        self.topicList[topic].retainedMessage = message
    else
        table.insert(self.topicList[topic].messages, message)
    end
    self.messageIndex[message.id] = message
    message.readBy = {}
    return true, message.id

end

---@param clientID number
---@param topic string
---@return boolean success
function MQTTBroker:subscribe(clientID, topic)
    if self.clientList[clientID] == nil then
        self.clientList[clientID] = {
            timeoutDuration = self.defaultTimeout,
            subscribedToTopic = {}
        }
    end
    local client = self.clientList[clientID]
    ---@cast client MQTTBroker_Client
    client.lastSeen = os.time()
    
    table.insert(client.subscribedToTopic, topic)
    if self.topicList[topic] == nil then
        self.topicList[topic] = self:createEmptyTopic()
    end
    table.insert(self.topicList[topic].subscribedClients, clientID)
    
    return true

end

---@param clientID number
---@param topic string
---@return boolean success
function MQTTBroker:unsubscribe(clientID, topic)
    return true
end

---@param clientID number
---@return MQTT_message[]
function MQTTBroker:getMessagesForClient(clientID)
    return {}
end


---@param clientID number
---@param topic string
---@return boolean success
function MQTTBroker:markAsRead(clientID, topic)
    return true
end

---@return number deletedMessages
function MQTTBroker:expireMessages()
    return 0
end

---@param topic string
---@return boolean    
function MQTTBroker:pruneTopic(topic)
    return true
end

---Register the last will of a client (In case of a timeout)
---@param clientID number
---@param topic string
---@param message MQTT_message
---@param timeoutDuration number in seconds
---@return boolean
function MQTTBroker:registerLastWillMessage(clientID, topic, message, timeoutDuration)
    return true
end

---comment
---@return integer
function MQTTBroker:checkClientTimeouts()
    return 0
end

return MQTTBroker