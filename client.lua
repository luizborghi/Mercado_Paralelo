local QBCore = exports['qb-core']:GetCoreObject()
local currentOrder = nil
local deliveryBlip = nil
local ambushActive = false

-- Função para abrir a interface do tablet
local function OpenBlackmarket()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openTablet',
        categories = Config.Categories,
        items = Config.Items
    })
end

-- Função para fechar a interface
local function CloseBlackmarket()
    SetNuiFocus(false, false)
    SendNUIMessage({action = 'closeTablet'})
end

-- Usar tablet do inventário
RegisterNetEvent('qb-blackmarket:client:useTablet', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Animação de usar tablet
    lib.requestAnimDict('amb@world_human_seat_wall_tablet@female@base')
    TaskPlayAnim(ped, 'amb@world_human_seat_wall_tablet@female@base', 'base', 8.0, -8.0, -1, 50, 0, false, false, false)
    
    Wait(1000)
    OpenBlackmarket()
end)

-- Comando para abrir mercado negro
if Config.UseCommand then
    RegisterCommand(Config.Command, function()
        OpenBlackmarket()
    end)
end

-- Callback NUI para fazer pedido
RegisterNUICallback('placeOrder', function(data, cb)
    TriggerServerEvent('qb-blackmarket:server:placeOrder', data)
    cb('ok')
end)

-- Callback NUI para fechar tablet
RegisterNUICallback('closeTablet', function(data, cb)
    CloseBlackmarket()
    ClearPedTasks(PlayerPedId())
    cb('ok')
end)

-- Evento para iniciar entrega
RegisterNetEvent('qb-blackmarket:client:startDelivery', function(orderData)
    currentOrder = orderData
    CloseBlackmarket()
    ClearPedTasks(PlayerPedId())
    
    -- Escolher local de entrega aleatório
    local dropoffLocation = Config.DropoffLocations[math.random(#Config.DropoffLocations)]
    currentOrder.location = dropoffLocation
    
    -- Criar blip no mapa
    deliveryBlip = AddBlipForCoord(dropoffLocation.coords.x, dropoffLocation.coords.y, dropoffLocation.coords.z)
    SetBlipSprite(deliveryBlip, 478)
    SetBlipColour(deliveryBlip, 1)
    SetBlipScale(deliveryBlip, 0.8)
    SetBlipAsShortRange(deliveryBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Texts.delivery_blip)
    EndTextCommandSetBlipName(deliveryBlip)
    
    -- Notificação
    lib.notify({
        title = 'Mercado Negro',
        description = Config.Texts.order_placed,
        type = 'success'
    })
    
    -- Iniciar thread de verificação de entrega
    CreateThread(function()
        while currentOrder do
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local distance = #(coords - currentOrder.location.coords)
            
            if distance < 3.0 then
                -- Mostrar texto de interação
                lib.showTextUI('[E] Coletar Pedido')
                
                if IsControlJustPressed(0, 38) then -- E key
                    lib.hideTextUI()
                    CollectOrder()
                    break
                end
            elseif distance < 10.0 then
                lib.hideTextUI()
            end
            
            Wait(0)
        end
    end)
    
    -- Sistema de risco de emboscada
    if Config.RiskSystem then
        CreateThread(function()
            Wait(math.random(10000, 30000)) -- Esperar entre 10-30 segundos
            CheckForAmbush()
        end)
    end
end)

-- Função para coletar pedido
function CollectOrder()
    if not currentOrder then return end
    
    local ped = PlayerPedId()
    
    -- Animação de coleta
    lib.requestAnimDict('mp_common')
    TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, 2000, 0, 0, false, false, false)
    
    -- Barra de progresso
    if lib.progressBar({
        duration = 3000,
        label = 'Coletando itens...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    }) then
        -- Dar itens ao jogador
        TriggerServerEvent('qb-blackmarket:server:giveItems', currentOrder)
        
        -- Limpar blip e pedido
        if deliveryBlip then
            RemoveBlip(deliveryBlip)
            deliveryBlip = nil
        end
        
        currentOrder = nil
        
        lib.notify({
            title = 'Mercado Negro',
            description = Config.Texts.order_collected,
            type = 'success'
        })
    end
end

-- Função para verificar emboscada
function CheckForAmbush()
    if not currentOrder or ambushActive then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Contar jogadores próximos
    local nearbyPlayers = 0
    for _, player in pairs(GetActivePlayers()) do
        local otherPed = GetPlayerPed(player)
        if otherPed ~= ped then
            local otherCoords = GetEntityCoords(otherPed)
            if #(coords - otherCoords) < Config.RiskRadius then
                nearbyPlayers = nearbyPlayers + 1
            end
        end
    end
    
    -- Calcular chance de emboscada
    local category = nil
    for _, cat in pairs(Config.Categories) do
        for _, item in pairs(currentOrder.items) do
            for _, configItem in pairs(Config.Items) do
                if configItem.name == item.name and configItem.category == cat.name then
                    category = cat
                    break
                end
            end
        end
    end
    
    local riskChance = Config.BaseRiskChance
    if category then
        riskChance = riskChance * category.riskMultiplier
    end
    riskChance = riskChance + (nearbyPlayers * Config.RiskPerPlayer)
    
    -- Verificar se ocorre emboscada
    if math.random(100) <= riskChance then
        TriggerAmbush()
    end
end

-- Função para triggerar emboscada
function TriggerAmbush()
    if ambushActive then return end
    ambushActive = true
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Notificação de aviso
    lib.notify({
        title = 'Mercado Negro',
        description = Config.Texts.ambush_warning,
        type = 'error'
    })
    
    -- Spawnar NPCs inimigos
    local spawnedNPCs = {}
    for i = 1, math.random(2, 4) do
        local npcData = Config.AmbushNPCs[math.random(#Config.AmbushNPCs)]
        local spawnCoords = coords + vector3(
            math.random(-20, 20),
            math.random(-20, 20),
            0
        )
        
        lib.requestModel(npcData.model)
        local npc = CreatePed(4, GetHashKey(npcData.model), spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)
        
        -- Dar arma ao NPC
        GiveWeaponToPed(npc, GetHashKey(npcData.weapon), 100, false, true)
        SetPedCombatAttributes(npc, 46, true)
        SetPedCombatAttributes(npc, 0, false)
        SetPedCombatRange(npc, 0)
        SetPedCombatMovement(npc, 3)
        TaskCombatPed(npc, ped, 0, 16)
        
        table.insert(spawnedNPCs, npc)
    end
    
    -- Thread para verificar fim da emboscada
    CreateThread(function()
        while ambushActive do
            local aliveNPCs = 0
            for _, npc in pairs(spawnedNPCs) do
                if DoesEntityExist(npc) and not IsEntityDead(npc) then
                    aliveNPCs = aliveNPCs + 1
                end
            end
            
            if aliveNPCs == 0 then
                ambushActive = false
                lib.notify({
                    title = 'Mercado Negro',
                    description = Config.Texts.ambush_survived,
                    type = 'success'
                })
                break
            end
            
            Wait(1000)
        end
        
        -- Limpar NPCs mortos
        for _, npc in pairs(spawnedNPCs) do
            if DoesEntityExist(npc) then
                DeleteEntity(npc)
            end
        end
    end)
end

-- Limpar recursos ao sair
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if deliveryBlip then
            RemoveBlip(deliveryBlip)
        end
        CloseBlackmarket()
    end
end)
