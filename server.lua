local QBCore = exports['qb-core']:GetCoreObject()

-- Adicionar item do tablet ao iniciar
CreateThread(function()
    Wait(1000)
    -- Registrar item do tablet se não existir
    -- Isso deve ser feito no seu sistema de itens
end)

-- Usar tablet
QBCore.Functions.CreateUseableItem(Config.TabletItem, function(source, item)
    TriggerClientEvent('qb-blackmarket:client:useTablet', source)
end)

-- Evento para fazer pedido
RegisterNetEvent('qb-blackmarket:server:placeOrder', function(orderData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Calcular preço total
    local totalPrice = 0
    for _, item in pairs(orderData.items) do
        for _, configItem in pairs(Config.Items) do
            if configItem.name == item.name then
                totalPrice = totalPrice + (configItem.price * item.quantity)
                break
            end
        end
    end
    
    -- Verificar se o jogador tem dinheiro suficiente
    if Player.PlayerData.money.cash < totalPrice then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Mercado Negro',
            description = Config.Texts.not_enough_money,
            type = 'error'
        })
        return
    end
    
    -- Remover dinheiro
    Player.Functions.RemoveMoney('cash', totalPrice)
    
    -- Iniciar entrega
    TriggerClientEvent('qb-blackmarket:client:startDelivery', src, orderData)
end)

-- Evento para dar itens após coleta
RegisterNetEvent('qb-blackmarket:server:giveItems', function(orderData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Dar itens ao jogador
    for _, item in pairs(orderData.items) do
        Player.Functions.AddItem(item.name, item.quantity)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], 'add', item.quantity)
    end
end)
