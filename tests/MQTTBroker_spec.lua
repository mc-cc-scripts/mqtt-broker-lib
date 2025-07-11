---@class are
---@field same function
---@field equal function
---@field equals function

---@class is
---@field truthy function
---@field falsy function
---@field not_true function
---@field not_false function

---@class has
---@field error function
---@field errors function

---@class assert
---@field are are
---@field is is
---@field are_not are
---@field is_not is
---@field has has
---@field has_no has
---@field True function
---@field False function
---@field has_error function
---@field is_false function
---@field is_true function
---@field equal function
assert = assert

package.path = package.path .. ";"
    .."libs/?.lua;"
    .."libs/peripherals/?.lua;"

local MQTTBroker = require("mqttBroker")

describe("Basic Tests", function()
    it("loaded", function()
        assert.is.truthy(MQTTBroker)
    end)
    describe("Publish", function()
        it("SenderID", function ()
            assert.True(MQTTBroker:publish("test", {sender = 2}))
            assert.False(MQTTBroker:publish("test", {}))
        end)
        it("Publish", function()
            local ok, id = MQTTBroker:publish("test", {sender = 2, payload = "test payload"})
            local ok2, id2 = MQTTBroker:publish("test", {sender = 2, payload = "test payload 2"})
            assert.True(ok)
            assert.True(ok2)
            assert.are.same(MQTTBroker:getMessageByID(id).payload, "test payload")
            assert.are.same(MQTTBroker:getMessageByID(id2).payload, "test payload 2")
        end)
    end)
end)