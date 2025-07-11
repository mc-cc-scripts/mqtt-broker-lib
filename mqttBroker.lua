---@class MQTTBroker
local MQTTBroker = {} 

    local ERRORText = {
        ["validate_MessageWrongType"] = "Message is not of type table! It is type %s",
        ["validate_MissingSender"] = "Sender_ID is Missing",
    }

    MQTTBroker.defaultTimeOut = 300 * 1000 -- 5 minutes

    ---@type MQTTBroker_ClientList
    MQTTBroker.clientList = {}

    ---@type nil | fun(topic, message): boolean, (nil | string)
    MQTTBroker.validator = nil

    ---@type MQTT_messages
    MQTTBroker.messages = {}

    ---@private
    MQTTBroker.messageIndex = {}
    
    ---@param id any
    ---@return MQTT_message | nil
    function MQTTBroker:getMessageByID(id)
        return self.messageIndex[id]
    end



    ---@param topic string
    ---@param message MQTT_message
    ---@return boolean
    ---@return string | nil
    function MQTTBroker:validatePayload(topic, message)
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
        local ok, err = self:validatePayload(topic, message) 
        if not ok then
            return false, err
        end



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

        if not message.retain and not message.ttl then
            message.ttl = self.defaultTimeOut
        end

        message.readBy = {}

        if self.messages[topic] == nil then
            self.messages[topic] = {}
        end

        table.insert(self.messages[topic], message)
        self.messageIndex[message.id] = message
        return true, message.id
    end

    ---@param clientID number
    ---@param topic string
    ---@return boolean success
    function MQTTBroker:subscribe(clientID, topic)
        return true
    end

    ---@param clientID number
    ---@param topic string
    ---@return boolean success
    function MQTTBroker:unsubscribe(clientID, topic)
        return true
    end

    ---@param clientID number
    ---@return MQTT_messages
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