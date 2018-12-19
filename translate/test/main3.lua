-- $Name: Translate test$
-- instead_version "3.2.0"
loadmod "translate";
translate:set_source('en'); -- translate from English
translate:init();

room {
  nam = 'main';
  disp = __('Translate');
  dsc = __("This is the English text. Change your language settings to Russian and restart the game.");
}
