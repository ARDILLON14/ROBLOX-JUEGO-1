--!strict
-- Platform: ¿el jugador usa pantalla táctil sin teclado (móvil/tableta)? Solo tiene sentido en el cliente.

local UserInputService = game:GetService("UserInputService")

local Platform = {}

function Platform.isTouch(): boolean
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

return Platform
