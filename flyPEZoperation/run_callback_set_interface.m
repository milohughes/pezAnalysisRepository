%インタフェース選択GUIのコールバック設定

set(K.Gigabit_radio,'Callback',{@Gigabit_radio_Callback});
set(K.IEEE_radio,'Callback',{@IEEE_radio_Callback});
set(K.PCI_radio,'Callback',{@PCI_radio_Callback});
set(K.OK_button,'Callback',{@OK_button_Callback});
set(K.Detect_auto_radio,'Callback',{@Detect_auto_radio_Callback});
set(K.Detect_normal_radio,'Callback',{@Detect_normal_radio_Callback});
set(K.Detect_normal4_edit,'KeyPressFcn',{@Detect_normal4_edit_KeyPressFcn});
set(K.Detect_auto3_edit,'KeyPressFcn',{@Detect_auto3_edit_KeyPressFcn});