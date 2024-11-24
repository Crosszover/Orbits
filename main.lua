-- Variables globales
local camara
local planetas
local sol
local asteroides
local tiempoSimulado
local velocidadSimulacion
local velocidadSimulacionAnterior
local mostrarNombres
local mostrarEstelas
local maxEstelas
local mouse
local centroX
local centroY

function love.load()
    -- Configuración de la ventana y fuente
    love.window.setMode(1200, 800, {resizable = true})
    fuente = love.graphics.newFont(14)
    love.graphics.setFont(fuente)
    
    -- Inicialización de variables globales
    tiempoSimulado = 0
    velocidadSimulacion = 1
    velocidadSimulacionAnterior = 1
    mostrarNombres = true
    mostrarEstelas = true
    maxEstelas = 100
    
    -- Variables de cámara
    camara = {
        x = 0,
        y = 0,
        zoom = 0.15,
        velocidadMovimiento = 1000,
        zoomMin = 0.01,
        zoomMax = 10.0
    }
    
    -- Variables del ratón
    mouse = {
        clickX = 0,
        clickY = 0,
        isDragging = false
    }
    
    -- Factor de escala (1 UA = 149,597,870 km = 300 píxeles)
    local escalaDistancia = 300  -- píxeles por UA
    local escalaTamaño = 15     -- Factor para hacer los planetas visibles
    
    -- Centro del sistema
    centroX = love.graphics.getWidth() / 2
    centroY = love.graphics.getHeight() / 2
    
    -- Sol
    sol = {
        x = centroX,
        y = centroY,
        radio = (1392684/2) / 149597870 * escalaDistancia * escalaTamaño, -- Radio del Sol en UA
        color = {1, 1, 0}
    }
    
    -- Planetas
    planetas = {
        {
            nombre = "Mercurio",
            distancia = 0.387 * escalaDistancia,
            radio = (4879/2) / 149597870 * escalaDistancia * escalaTamaño,
            periodo = 87.97,
            color = {0.7, 0.7, 0.7},
            angulo = 0,
            estelas = {}
        },
        {
            nombre = "Venus",
            distancia = 0.723 * escalaDistancia,
            radio = (12104/2) / 149597870 * escalaDistancia * escalaTamaño,
            periodo = 224.7,
            color = {0.9, 0.7, 0.5},
            angulo = 0,
            estelas = {}
        },
        {
            nombre = "Tierra",
            distancia = 1.0 * escalaDistancia,
            radio = (12742/2) / 149597870 * escalaDistancia * escalaTamaño,
            periodo = 365.26,
            color = {0.2, 0.5, 1},
            angulo = 0,
            estelas = {},
            lunas = {
                {
                    nombre = "Luna",
                    distancia = 0.00257 * escalaDistancia,
                    radio = (3474/2) / 149597870 * escalaDistancia * escalaTamaño,
                    periodo = 27.322,
                    color = {0.8, 0.8, 0.8},
                    angulo = 0
                }
            }
        },
        {
            nombre = "Marte",
            distancia = 1.524 * escalaDistancia,
            radio = (6779/2) / 149597870 * escalaDistancia * escalaTamaño,
            periodo = 686.98,
            color = {1, 0.4, 0},
            angulo = 0,
            estelas = {}
        },
        {
            nombre = "Júpiter",
            distancia = 5.203 * escalaDistancia,
            radio = (139822/2) / 149597870 * escalaDistancia * escalaTamaño,
            periodo = 4332.59,
            color = {0.8, 0.6, 0.4},
            angulo = 0,
            estelas = {}
        },
        {
            nombre = "Saturno",
            distancia = 9.537 * escalaDistancia,
            radio = (116464/2) / 149597870 * escalaDistancia * escalaTamaño,
            periodo = 10759.22,
            color = {0.9, 0.8, 0.5},
            angulo = 0,
            estelas = {},
            anillos = {
                radio = (280000/2) / 149597870 * escalaDistancia * escalaTamaño
            }
        },
        {
            nombre = "Urano",
            distancia = 19.191 * escalaDistancia,
            radio = (50724/2) / 149597870 * escalaDistancia * escalaTamaño,
            periodo = 30688.5,
            color = {0.5, 0.8, 0.9},
            angulo = 0,
            estelas = {}
        },
        {
            nombre = "Neptuno",
            distancia = 30.069 * escalaDistancia,
            radio = (49244/2) / 149597870 * escalaDistancia * escalaTamaño,
            periodo = 60182,
            color = {0.2, 0.3, 0.9},
            angulo = 0,
            estelas = {}
        }
    }
    
    -- Cinturón de asteroides
    asteroides = {}
    local numAsteroides = 1000
    for i = 1, numAsteroides do
        table.insert(asteroides, {
            distancia = (love.math.random() * (3.2 - 2.2) + 2.2) * escalaDistancia,
            angulo = love.math.random() * math.pi * 2,
            velocidad = love.math.random() * 0.5 + 0.5,
            tamaño = love.math.random() * 0.8 + 0.2
        })
    end
end

function love.update(dt)
    actualizarCamara(dt)
    
    if velocidadSimulacion > 0 then
        local diasPorFrame = dt * velocidadSimulacion
        tiempoSimulado = tiempoSimulado + diasPorFrame
        
        -- Actualizar planetas
        for _, planeta in ipairs(planetas) do
            planeta.angulo = planeta.angulo + (2 * math.pi * diasPorFrame / planeta.periodo)
            
            if mostrarEstelas then
                local x = centroX + math.cos(planeta.angulo) * planeta.distancia
                local y = centroY + math.sin(planeta.angulo) * planeta.distancia
                table.insert(planeta.estelas, 1, {x = x, y = y})
                if #planeta.estelas > maxEstelas then
                    table.remove(planeta.estelas)
                end
            end
            
            if planeta.lunas then
                for _, luna in ipairs(planeta.lunas) do
                    luna.angulo = luna.angulo + (2 * math.pi * diasPorFrame / luna.periodo)
                end
            end
        end
        
        -- Actualizar asteroides
        for _, asteroide in ipairs(asteroides) do
            asteroide.angulo = asteroide.angulo + dt * asteroide.velocidad * velocidadSimulacion
        end
    end
end

function actualizarCamara(dt)
    local velocidadActual = camara.velocidadMovimiento * dt / camara.zoom
    if love.keyboard.isDown('w') then camara.y = camara.y + velocidadActual end
    if love.keyboard.isDown('s') then camara.y = camara.y - velocidadActual end
    if love.keyboard.isDown('a') then camara.x = camara.x + velocidadActual end
    if love.keyboard.isDown('d') then camara.x = camara.x - velocidadActual end
    
    if mouse.isDragging then
        local mouseX, mouseY = love.mouse.getPosition()
        camara.x = camara.x - (mouse.clickX - mouseX) / camara.zoom
        camara.y = camara.y - (mouse.clickY - mouseY) / camara.zoom
        mouse.clickX, mouse.clickY = mouseX, mouseY
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0, 0, 0.1)
    
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    love.graphics.scale(camara.zoom)
    love.graphics.translate(-love.graphics.getWidth()/2 + camara.x, -love.graphics.getHeight()/2 + camara.y)
    
    -- Dibujar órbitas
    love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
    for _, planeta in ipairs(planetas) do
        love.graphics.circle("line", sol.x, sol.y, planeta.distancia)
    end
    
    -- Dibujar asteroides
    love.graphics.setColor(0.5, 0.5, 0.5, 0.3)
    for _, asteroide in ipairs(asteroides) do
        local x = sol.x + math.cos(asteroide.angulo) * asteroide.distancia
        local y = sol.y + math.sin(asteroide.angulo) * asteroide.distancia
        love.graphics.circle("fill", x, y, asteroide.tamaño)
    end
    
    -- Dibujar estelas
    if mostrarEstelas then
        for _, planeta in ipairs(planetas) do
            for i, estela in ipairs(planeta.estelas) do
                local alpha = 1 - (i / #planeta.estelas)
                love.graphics.setColor(planeta.color[1], planeta.color[2], planeta.color[3], alpha * 0.3)
                love.graphics.circle("fill", estela.x, estela.y, 1)
            end
        end
    end
    
    -- Dibujar sol
    love.graphics.setColor(sol.color)
    love.graphics.circle("fill", sol.x, sol.y, sol.radio)
    
    -- Dibujar planetas
    for _, planeta in ipairs(planetas) do
        local x = sol.x + math.cos(planeta.angulo) * planeta.distancia
        local y = sol.y + math.sin(planeta.angulo) * planeta.distancia
        
        if planeta.anillos then
            love.graphics.setColor(planeta.color[1], planeta.color[2], planeta.color[3], 0.5)
            local anguloInclinacion = math.pi / 7
            for i = 1, 5 do
                local radio = planeta.anillos.radio - (i-1) * 2
                love.graphics.ellipse("line", x, y, radio, radio * math.cos(anguloInclinacion))
            end
        end
        
        love.graphics.setColor(planeta.color)
        love.graphics.circle("fill", x, y, planeta.radio)
        
        if planeta.lunas then
            for _, luna in ipairs(planeta.lunas) do
                local lx = x + math.cos(luna.angulo) * luna.distancia
                local ly = y + math.sin(luna.angulo) * luna.distancia
                love.graphics.setColor(luna.color)
                love.graphics.circle("fill", lx, ly, luna.radio)
            end
        end
        
        if mostrarNombres then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(planeta.nombre, x + planeta.radio + 5, y - 12)
            local periodoTexto
            if planeta.periodo > 365 then
                periodoTexto = string.format("%.1f años", planeta.periodo / 365)
            else
                periodoTexto = string.format("%.1f días", planeta.periodo)
            end
            love.graphics.print(periodoTexto, x + planeta.radio + 5, y + 2)
        end
    end
    
    love.graphics.pop()
    
    dibujarUI()
end

function dibujarUI()
    love.graphics.setColor(1, 1, 1)
    
    local dias = math.floor(tiempoSimulado)
    local años = math.floor(dias / 365)
    local diasRestantes = dias % 365
    
    love.graphics.print("Tiempo simulado:", 10, 10)
    if años > 0 then
        love.graphics.print(string.format("%d años, %d días", años, diasRestantes), 10, 30)
    else
        love.graphics.print(string.format("%d días", dias), 10, 30)
    end
    
    local textoVelocidad = velocidadSimulacion == 0 and "PAUSADO" or 
                          string.format("Velocidad: x%.1f", velocidadSimulacion)
    love.graphics.print(textoVelocidad, 10, 50)
    love.graphics.print(string.format("Zoom: x%.2f", camara.zoom), 10, 70)
    
    love.graphics.print("Controles:", 10, 100)
    love.graphics.print("ESPACIO: Pausar/Reanudar", 10, 120)
    love.graphics.print("↑/↓: Ajustar velocidad", 10, 140)
    love.graphics.print("R: Reiniciar tiempo", 10, 160)
    love.graphics.print("WASD: Mover vista", 10, 180)
    love.graphics.print("+/-: Zoom", 10, 200)
    love.graphics.print("N: Nombres", 10, 220)
    love.graphics.print("E: Estelas", 10, 240)
    love.graphics.print("ESC: Salir", 10, 260)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "n" then
        mostrarNombres = not mostrarNombres
    elseif key == "e" then
        mostrarEstelas = not mostrarEstelas
        if not mostrarEstelas then
            for _, planeta in ipairs(planetas) do
                planeta.estelas = {}
            end
        end
    elseif key == "up" then
        velocidadSimulacion = velocidadSimulacion * 2
    elseif key == "down" then
        velocidadSimulacion = math.max(1, velocidadSimulacion / 2)
    elseif key == "space" then
        if velocidadSimulacion ~= 0 then
            velocidadSimulacionAnterior = velocidadSimulacion
            velocidadSimulacion = 0
        else
            velocidadSimulacion = velocidadSimulacionAnterior
        end
    elseif key == "r" then
        tiempoSimulado = 0
        -- Reiniciar posiciones de los planetas
        for _, planeta in ipairs(planetas) do
            planeta.angulo = 0
            planeta.estelas = {}
            if planeta.lunas then
                for _, luna in ipairs(planeta.lunas) do
                    luna.angulo = 0
                end
            end
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 3 then -- Botón derecho del ratón
        mouse.isDragging = true
        mouse.clickX, mouse.clickY = x, y
    end
end

function love.mousereleased(x, y, button)
    if button == 3 then
        mouse.isDragging = false
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        camara.zoom = math.min(camara.zoom * 1.1, camara.zoomMax)
    else
        camara.zoom = math.max(camara.zoom / 1.1, camara.zoomMin)
    end
end