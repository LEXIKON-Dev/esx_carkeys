Locales = Locales or {}

function GetLocale()
    return Locales[Config.Locale] or Locales['de']
end
