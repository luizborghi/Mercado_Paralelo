Config = {}

-- Configurações Gerais
Config.Framework = 'qbox' -- 'qbcore' ou 'qbox'
Config.UseCommand = true -- Permitir comando para abrir o mercado
Config.Command = 'blackmarket' -- Comando para abrir
Config.TabletItem = 'blackmarket_tablet' -- Item do tablet

-- Configurações de Risco
Config.RiskSystem = true -- Sistema de risco ativado
Config.BaseRiskChance = 15 -- Chance base de emboscada (%)
Config.RiskPerPlayer = 5 -- Risco adicional por jogador próximo (%)
Config.RiskRadius = 100.0 -- Raio para contar jogadores próximos

-- Localizações de Entrega
Config.DropoffLocations = {
    {coords = vector3(1275.5, -1710.2, 54.8), heading = 120.0},
    {coords = vector3(-1037.8, -2738.5, 20.2), heading = 240.0},
    {coords = vector3(2558.4, 382.0, 108.6), heading = 0.0},
    {coords = vector3(-2072.4, -317.2, 13.3), heading = 180.0},
    {coords = vector3(1728.8, 3309.5, 41.2), heading = 90.0}
}

-- NPCs de Emboscada
Config.AmbushNPCs = {
    {model = 'g_m_y_lost_01', weapon = 'WEAPON_PISTOL'},
    {model = 'g_m_y_lost_02', weapon = 'WEAPON_MICROSMG'},
    {model = 'g_m_y_lost_03', weapon = 'WEAPON_PISTOL'},
    {model = 'a_m_m_hillbilly_01', weapon = 'WEAPON_SAWNOFFSHOTGUN'}
}

-- Categorias e Itens
Config.Categories = {
    {
        name = 'weapons',
        label = 'Armas',
        icon = 'fas fa-gun',
        riskMultiplier = 2.0
    },
    {
        name = 'drugs',
        label = 'Drogas',
        icon = 'fas fa-pills',
        riskMultiplier = 1.5
    },
    {
        name = 'electronics',
        label = 'Eletrônicos',
        icon = 'fas fa-laptop',
        riskMultiplier = 1.0
    },
    {
        name = 'materials',
        label = 'Materiais',
        icon = 'fas fa-tools',
        riskMultiplier = 0.8
    }
}

Config.Items = {
    -- Armas
    {
        name = 'weapon_pistol',
        label = 'Pistola',
        category = 'weapons',
        price = 15000,
        image = 'weapon_pistol.png',
        description = 'Pistola padrão para proteção pessoal'
    },
    {
        name = 'weapon_microsmg',
        label = 'Micro SMG',
        category = 'weapons',
        price = 25000,
        image = 'weapon_microsmg.png',
        description = 'Submetralhadora compacta'
    },
    
    -- Drogas
    {
        name = 'coke_brick',
        label = 'Tijolo de Cocaína',
        category = 'drugs',
        price = 8000,
        image = 'coke_brick.png',
        description = 'Cocaína pura em tijolo'
    },
    {
        name = 'weed_brick',
        label = 'Tijolo de Maconha',
        category = 'drugs',
        price = 3000,
        image = 'weed_brick.png',
        description = 'Maconha prensada de alta qualidade'
    },
    
    -- Eletrônicos
    {
        name = 'laptop_hacked',
        label = 'Laptop Hackeado',
        category = 'electronics',
        price = 5000,
        image = 'laptop.png',
        description = 'Laptop com softwares ilegais instalados'
    },
    {
        name = 'phone_encrypted',
        label = 'Telefone Criptografado',
        category = 'electronics',
        price = 2500,
        image = 'phone.png',
        description = 'Telefone com criptografia militar'
    },
    
    -- Materiais
    {
        name = 'lockpick_advanced',
        label = 'Gazua Avançada',
        category = 'materials',
        price = 500,
        image = 'lockpick.png',
        description = 'Ferramenta para abrir fechaduras complexas'
    },
    {
        name = 'thermite',
        label = 'Termite',
        category = 'materials',
        price = 1200,
        image = 'thermite.png',
        description = 'Explosivo para cortar metal'
    }
}

-- Textos em Português
Config.Texts = {
    tablet_use = 'Pressione ~INPUT_CONTEXT~ para usar o tablet',
    order_placed = 'Pedido realizado! Vá até o local de entrega.',
    order_collected = 'Itens coletados com sucesso!',
    ambush_warning = 'Cuidado! Você está sendo seguido...',
    not_enough_money = 'Você não tem dinheiro suficiente!',
    delivery_blip = 'Entrega do Mercado Negro',
    ambush_survived = 'Você sobreviveu à emboscada!',
    order_failed = 'Pedido cancelado devido à emboscada!'
}
