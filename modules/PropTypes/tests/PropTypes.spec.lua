local ServerScriptService = game:GetService("ServerScriptService")

return function()
    local PropTypes = require(ServerScriptService.PropTypes)

    describe("primitives", function()
        local primitiveValues = {
            string = "foo",
            number = 1.2,
            table = {},
            boolean = true,
            thread = coroutine.create(function() end),
            coroutine = coroutine.create(function() end),
            Axes = Axes.new(),
            BrickColor = BrickColor.Random(),
            CFrame = CFrame.new(),
            Color3 = Color3.new(1, 1, 1),
            ColorSequence = ColorSequence.new(Color3.new(0, 0, 0)),
            ColorSequenceKeypoint = ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
            Faces = Faces.new(),
            Instance = Instance.new("Folder"),
            NumberRange = NumberRange.new(0),
            NumberSequence = NumberSequence.new(0),
            NumberSequenceKeypoint = NumberSequenceKeypoint.new(0, 0, 0),
            PhysicalProperties = PhysicalProperties.new(1),
            Ray = Ray.new(),
            Rect = Rect.new(),
            Region3 = Region3.new(),
            Region3int16 = Region3int16.new(),
            TweenInfo = TweenInfo.new(),
            UDim = UDim.new(),
            UDim2 = UDim2.new(),
            Vector2 = Vector2.new(),
            Vector3 = Vector3.new(),
            Vector3int16 = Vector3int16.new(),
            Enum = Enum.Font,
            EnumItem = Enum.Font.SourceSans,
            userdata = Color3.new(),
            func = function() end,
        }

        it("should succeed for valid values", function()
            for primitiveType, testValue in pairs(primitiveValues) do
                assert(PropTypes[primitiveType](testValue))
            end
        end)

        it("should fail for invalid values", function()
            for primitiveType, _ in pairs(primitiveValues) do
                local success, _ = PropTypes[primitiveType](nil)
                expect(success).to.equal(false)
            end
        end)
    end)

    describe("some", function()
        it("should succeed for any value", function()
            for _, value in ipairs({ 1, true, print, Instance.new("Folder"), "foo" }) do
                local success, _ = PropTypes.some(value)
                expect(success).to.equal(true)
            end
        end)

        it("should fail for nil", function()
            expect(PropTypes.some(nil)).to.equal(false)
        end)
    end)

    describe("all", function()
        it("should create functions", function()
            expect(typeof(PropTypes.all(PropTypes.number, PropTypes.string))).to.equal("function")
        end)

        it("should evaluate sub-validators in order", function()
            local lastValidator = 0

            local validator = PropTypes.all(
                function()
                    lastValidator = 1
                    return true
                end,
                function()
                    lastValidator = 2
                    return true
                end,
                function()
                    lastValidator = 3
                    return true
                end
            )

            validator()
            expect(lastValidator).to.equal(3)
        end)

        it("should fail with the message of the failing validator", function()
            local lastValidator = 0
            local validator = PropTypes.all(
                function()
                    lastValidator = 1
                    return true, "foo"
                end,
                function()
                    lastValidator = 2
                    return false, "bar"
                end,
                function()
                    lastValidator = 3
                    return true, "baz"
                end
            )

            local success, reason = validator()
            expect(lastValidator).to.equal(2)
            expect(success).to.equal(false)
            expect(reason).to.equal("bar")
        end)

        it("should succeed only if all validators succeed", function()
            local validator = PropTypes.all(
                function()
                    return true
                end,
                function()
                    return true
                end
            )

            expect(validator()).to.equal(true)
        end)
    end)

    describe("any", function()
        it("should create functions", function()
            expect(typeof(PropTypes.any(PropTypes.number, PropTypes.string))).to.equal("function")
        end)

        it("should evaluate validators in order", function()
            local lastValidator = 0

            local validator = PropTypes.any(
                function()
                    lastValidator = 1
                    return false
                end,
                function()
                    lastValidator = 2
                    return false
                end,
                function()
                    lastValidator = 3
                    return false
                end
            )

            validator()
            expect(lastValidator).to.equal(3)
        end)

        it("should succeed if any validator succeeds", function()
            local lastValidator = 0

            local validator = PropTypes.any(
                function()
                    lastValidator = 1
                    return false
                end,
                function()
                    lastValidator = 2
                    return true
                end,
                function()
                    lastValidator = 3
                    return false
                end
            )

            local success = validator()
            expect(lastValidator).to.equal(2)
            expect(success).to.equal(true)
        end)

        it("should fail with a reason if no validators succeed", function()
            local validator = PropTypes.any(
                function()
                    return false
                end,
                function()
                    return false
                end,
                function()
                    return false
                end
            )

            local success, reason = validator()
            expect(success).to.equal(false)
            expect(typeof(reason)).to.equal("string")
        end)
    end)

    describe("optional", function()
        it("should make optional validators", function()
            local validator = PropTypes.optional(PropTypes.number)
            expect(typeof(validator)).to.equal("function")
            expect(validator(nil)).to.equal(true)
            expect(validator(1)).to.equal(true)
            expect(validator("foo")).to.equal(false)
        end)

        it("should return the message of the inner validator if it failed", function()
            local validator = PropTypes.optional(function()
                return false, "foo"
            end)

            local success, reason = validator(1)
            expect(success).to.equal(false)
            expect(reason).to.equal("foo")
        end)
    end)

    describe("object", function()
        it("should make validators", function()
            expect(typeof(PropTypes.object({}))).to.equal("function")
        end)

        it("should fail for non-indexable types", function()
            local validator = PropTypes.object({})
            expect(validator(1)).to.equal(false)
            expect(validator("foo")).to.equal(false)
            expect(validator(function() end)).to.equal(false)
            expect(validator(nil)).to.equal(false)
        end)

        it("should invoke all sub-validators", function()
            local invoked = {}
            local validator = PropTypes.object({
                a = function()
                    invoked.a = true
                    return true
                end,
                b = function()
                    invoked.b = true
                    return false
                end,
            })

            validator({
                a = 1,
                b = 2,
            })
            expect(invoked.a).to.equal(true)
            expect(invoked.b).to.equal(true)
        end)

        it("should fail if any sub-validator fails", function()
            local validator = PropTypes.object({
                a = function()
                    return true
                end,
                b = function()
                    return false
                end,
            })

            local success, _ = validator({
                a = 1,
                b = 2,
            })
            expect(success).to.equal(false)
        end)

        it("should succeed if all validators succeed", function()
            local validator = PropTypes.object({
                a = function()
                    return true
                end,
                b = function()
                    return true
                end,
            })

            expect(validator({
                a = 1,
                b = 2,
            })).to.equal(true)
        end)
    end)

    describe("strictObject", function()
        it("should make validators", function()
            expect(typeof(PropTypes.strictObject({}))).to.equal("function")
        end)

        it("should fail for non-indexable types", function()
            local validator = PropTypes.strictObject({})
            expect(validator(1)).to.equal(false)
            expect(validator("foo")).to.equal(false)
            expect(validator(function() end)).to.equal(false)
            expect(validator(nil)).to.equal(false)
        end)

        it("should invoke all sub-validators", function()
            local invoked = {}
            local validator = PropTypes.strictObject({
                a = function()
                    invoked.a = true
                    return true
                end,
                b = function()
                    invoked.b = true
                    return false
                end,
            })

            validator({
                a = 1,
                b = 2,
            })
            expect(invoked.a).to.equal(true)
            expect(invoked.b).to.equal(true)
        end)

        it("should fail if any sub-validator fails", function()
            local validator = PropTypes.strictObject({
                a = function()
                    return true
                end,
                b = function()
                    return false
                end,
            })

            local success, _ = validator({
                a = 1,
                b = 2,
            })
            expect(success).to.equal(false)
        end)

        it("should succeed if all validators succeed", function()
            local validator = PropTypes.strictObject({
                a = function()
                    return true
                end,
                b = function()
                    return true
                end,
            })

            expect(validator({
                a = 1,
                b = 2,
            })).to.equal(true)
        end)

        it("should fail if an unspecified key is present", function()
            local validator = PropTypes.strictObject({
                a = function()
                    return true
                end,
                b = function()
                    return true
                end,
            })

            expect(validator({
                a = 1,
                b = 2,
                c = 3,
            })).to.equal(false)
        end)
    end)

    describe("enumOf", function()
        it("should make validators", function()
            expect(typeof(PropTypes.enumOf(Enum.Font))).to.equal("function")
        end)

        it("should fail if the value is not an EnumItem of the specified enum", function()
            local validator = PropTypes.enumOf(Enum.Font)
            expect(validator(nil)).to.equal(false)
            expect(validator(function() end)).to.equal(false)
            expect(validator(Enum.TextXAlignment.Left)).to.equal(false)
            expect(validator("Code")).to.equal(false)
            expect(validator(10)).to.equal(false)
            expect(validator(Enum.Font.SourceSans)).to.equal(true)
        end)

        it("should allow the string and numerical representations of EnumItems when allowCasting is true", function()
            local validator = PropTypes.enumOf(Enum.Font, true)
            expect(validator("Code")).to.equal(true)
            expect(validator(10)).to.equal(true)
            expect(validator(-1)).to.equal(false)
            expect(validator("NOT A FONT")).to.equal(false)
        end)
    end)

    describe("ofClass", function()
        it("should make validators", function()
            expect(typeof(PropTypes.ofClass("Part"))).to.equal("function")
        end)

        it("should check if the value is an instance descended from the class", function()
            local validator = PropTypes.ofClass("BasePart")
            expect(validator(Instance.new("Part"))).to.equal(true)
            expect(validator(Instance.new("CornerWedgePart"))).to.equal(true)
            expect(validator(Instance.new("Folder"))).to.equal(false)
            expect(validator(nil)).to.equal(false)
            expect(validator(1)).to.equal(false)
        end)
    end)
end