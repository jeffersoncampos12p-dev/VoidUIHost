--[[
    VoidUI - Internationalization System (i18n)
    Multi-language support with localization for pt-BR, en-US, es-ES.
    
    License: MIT
    Author: VoidUI Team
    Version: 2.0.0
]]

local Core = require(script.Parent.core.VoidCore)

local i18n = {
    _current = "en-US",
    _fallback = "en-US",
    _translations = {},
    _onChange = Core.Signal.new(),
}

-- ============================================================
-- Built-in Translations
-- ============================================================
i18n._translations["en-US"] = {
    -- Window
    ["window.close"] = "Close",
    ["window.minimize"] = "Minimize",
    ["window.maximize"] = "Maximize",
    ["window.search"] = "Search...",
    ["window.loading"] = "Loading...",
    
    -- Buttons
    ["button.ok"] = "OK",
    ["button.cancel"] = "Cancel",
    ["button.confirm"] = "Confirm",
    ["button.apply"] = "Apply",
    ["button.reset"] = "Reset",
    ["button.save"] = "Save",
    ["button.delete"] = "Delete",
    ["button.edit"] = "Edit",
    ["button.close"] = "Close",
    ["button.next"] = "Next",
    ["button.previous"] = "Previous",
    ["button.back"] = "Back",
    
    -- Dialogs
    ["dialog.confirmTitle"] = "Confirm Action",
    ["dialog.confirmMessage"] = "Are you sure you want to continue?",
    ["dialog.warningTitle"] = "Warning",
    ["dialog.errorTitle"] = "Error",
    ["dialog.infoTitle"] = "Information",
    
    -- Notifications
    ["notification.success"] = "Success",
    ["notification.warning"] = "Warning",
    ["notification.error"] = "Error",
    ["notification.info"] = "Information",
    ["notification.dismiss"] = "Dismiss",
    
    -- Common
    ["common.enabled"] = "Enabled",
    ["common.disabled"] = "Disabled",
    ["common.loading"] = "Loading",
    ["common.error"] = "Error",
    ["common.warning"] = "Warning",
    ["common.success"] = "Success",
    ["common.none"] = "None",
    ["common.default"] = "Default",
    ["common.custom"] = "Custom",
    ["common.all"] = "All",
    ["common.selected"] = "Selected",
    ["common.copy"] = "Copy",
    ["common.paste"] = "Paste",
    ["common.cut"] = "Cut",
    ["common.search"] = "Search",
    ["common.filter"] = "Filter",
    ["common.clear"] = "Clear",
    ["common.refresh"] = "Refresh",
    
    -- Theme
    ["theme.dark"] = "Dark",
    ["theme.light"] = "Light",
    ["theme.change"] = "Change Theme",
    ["theme.accent"] = "Accent Color",
    ["theme.transparency"] = "Transparency",
    ["theme.animations"] = "Animations",
    ["theme.blur"] = "Blur",
    
    -- Tabs
    ["tab.add"] = "Add Tab",
    ["tab.remove"] = "Remove Tab",
    ["tab.rename"] = "Rename Tab",
    
    -- Keyboard
    ["keyboard.pressKey"] = "Press a key...",
    ["keyboard.clearKeybind"] = "Clear Keybind",
    
    -- Misc
    ["misc.version"] = "Version",
    ["misc.credits"] = "Credits",
    ["misc.documentation"] = "Documentation",
}

i18n._translations["pt-BR"] = {
    -- Window
    ["window.close"] = "Fechar",
    ["window.minimize"] = "Minimizar",
    ["window.maximize"] = "Maximizar",
    ["window.search"] = "Pesquisar...",
    ["window.loading"] = "Carregando...",
    
    -- Buttons
    ["button.ok"] = "OK",
    ["button.cancel"] = "Cancelar",
    ["button.confirm"] = "Confirmar",
    ["button.apply"] = "Aplicar",
    ["button.reset"] = "Redefinir",
    ["button.save"] = "Salvar",
    ["button.delete"] = "Excluir",
    ["button.edit"] = "Editar",
    ["button.close"] = "Fechar",
    ["button.next"] = "Próximo",
    ["button.previous"] = "Anterior",
    ["button.back"] = "Voltar",
    
    -- Dialogs
    ["dialog.confirmTitle"] = "Confirmar Ação",
    ["dialog.confirmMessage"] = "Tem certeza de que deseja continuar?",
    ["dialog.warningTitle"] = "Aviso",
    ["dialog.errorTitle"] = "Erro",
    ["dialog.infoTitle"] = "Informação",
    
    -- Notifications
    ["notification.success"] = "Sucesso",
    ["notification.warning"] = "Aviso",
    ["notification.error"] = "Erro",
    ["notification.info"] = "Informação",
    ["notification.dismiss"] = "Dispensar",
    
    -- Common
    ["common.enabled"] = "Ativado",
    ["common.disabled"] = "Desativado",
    ["common.loading"] = "Carregando",
    ["common.error"] = "Erro",
    ["common.warning"] = "Aviso",
    ["common.success"] = "Sucesso",
    ["common.none"] = "Nenhum",
    ["common.default"] = "Padrão",
    ["common.custom"] = "Personalizado",
    ["common.all"] = "Todos",
    ["common.selected"] = "Selecionado",
    ["common.copy"] = "Copiar",
    ["common.paste"] = "Colar",
    ["common.cut"] = "Cortar",
    ["common.search"] = "Pesquisar",
    ["common.filter"] = "Filtrar",
    ["common.clear"] = "Limpar",
    ["common.refresh"] = "Atualizar",
    
    -- Theme
    ["theme.dark"] = "Escuro",
    ["theme.light"] = "Claro",
    ["theme.change"] = "Mudar Tema",
    ["theme.accent"] = "Cor de Destaque",
    ["theme.transparency"] = "Transparência",
    ["theme.animations"] = "Animações",
    ["theme.blur"] = "Desfoque",
    
    -- Tabs
    ["tab.add"] = "Adicionar Aba",
    ["tab.remove"] = "Remover Aba",
    ["tab.rename"] = "Renomear Aba",
    
    -- Keyboard
    ["keyboard.pressKey"] = "Pressione uma tecla...",
    ["keyboard.clearKeybind"] = "Limpar Atalho",
    
    -- Misc
    ["misc.version"] = "Versão",
    ["misc.credits"] = "Créditos",
    ["misc.documentation"] = "Documentação",
}

i18n._translations["es-ES"] = {
    -- Window
    ["window.close"] = "Cerrar",
    ["window.minimize"] = "Minimizar",
    ["window.maximize"] = "Maximizar",
    ["window.search"] = "Buscar...",
    ["window.loading"] = "Cargando...",
    
    -- Buttons
    ["button.ok"] = "OK",
    ["button.cancel"] = "Cancelar",
    ["button.confirm"] = "Confirmar",
    ["button.apply"] = "Aplicar",
    ["button.reset"] = "Restablecer",
    ["button.save"] = "Guardar",
    ["button.delete"] = "Eliminar",
    ["button.edit"] = "Editar",
    ["button.close"] = "Cerrar",
    ["button.next"] = "Siguiente",
    ["button.previous"] = "Anterior",
    ["button.back"] = "Atrás",
    
    -- Dialogs
    ["dialog.confirmTitle"] = "Confirmar Acción",
    ["dialog.confirmMessage"] = "¿Estás seguro de que deseas continuar?",
    ["dialog.warningTitle"] = "Advertencia",
    ["dialog.errorTitle"] = "Error",
    ["dialog.infoTitle"] = "Información",
    
    -- Notifications
    ["notification.success"] = "Éxito",
    ["notification.warning"] = "Advertencia",
    ["notification.error"] = "Error",
    ["notification.info"] = "Información",
    ["notification.dismiss"] = "Descartar",
    
    -- Common
    ["common.enabled"] = "Activado",
    ["common.disabled"] = "Desactivado",
    ["common.loading"] = "Cargando",
    ["common.error"] = "Error",
    ["common.warning"] = "Advertencia",
    ["common.success"] = "Éxito",
    ["common.none"] = "Ninguno",
    ["common.default"] = "Predeterminado",
    ["common.custom"] = "Personalizado",
    ["common.all"] = "Todos",
    ["common.selected"] = "Seleccionado",
    ["common.copy"] = "Copiar",
    ["common.paste"] = "Pegar",
    ["common.cut"] = "Cortar",
    ["common.search"] = "Buscar",
    ["common.filter"] = "Filtrar",
    ["common.clear"] = "Limpiar",
    ["common.refresh"] = "Actualizar",
    
    -- Theme
    ["theme.dark"] = "Oscuro",
    ["theme.light"] = "Claro",
    ["theme.change"] = "Cambiar Tema",
    ["theme.accent"] = "Color de Acento",
    ["theme.transparency"] = "Transparencia",
    ["theme.animations"] = "Animaciones",
    ["theme.blur"] = "Desenfoque",
    
    -- Tabs
    ["tab.add"] = "Añadir Pestaña",
    ["tab.remove"] = "Eliminar Pestaña",
    ["tab.rename"] = "Renombrar Pestaña",
    
    -- Keyboard
    ["keyboard.pressKey"] = "Presiona una tecla...",
    ["keyboard.clearKeybind"] = "Limpiar Atajo",
    
    -- Misc
    ["misc.version"] = "Versión",
    ["misc.credits"] = "Créditos",
    ["misc.documentation"] = "Documentación",
}

-- ============================================================
-- API
-- ============================================================
function i18n:SetLanguage(lang)
    if not self._translations[lang] then
        warn("[VoidUI] Language '" .. tostring(lang) .. "' is not available")
        return false
    end
    self._current = lang
    self._onChange:Fire(lang)
    return true
end

function i18n:GetLanguage()
    return self._current
end

function i18n:Available()
    local langs = {}
    for lang in pairs(self._translations) do
        table.insert(langs, lang)
    end
    return langs
end

function i18n:Translate(key, fallback)
    local lang = self._current
    local translations = self._translations[lang]
    if translations and translations[key] then
        return translations[key]
    end
    -- Try fallback
    if self._translations[self._fallback] and self._translations[self._fallback][key] then
        return self._translations[self._fallback][key]
    end
    -- Return the key or fallback
    return fallback or key
end

function i18n:T(key, fallback)
    return self:Translate(key, fallback)
end

function i18n:AddLanguage(lang, translations)
    self._translations[lang] = translations
end

function i18n:AddTranslations(lang, translations)
    if not self._translations[lang] then
        self._translations[lang] = {}
    end
    for k, v in pairs(translations) do
        self._translations[lang][k] = v
    end
end

return i18n
