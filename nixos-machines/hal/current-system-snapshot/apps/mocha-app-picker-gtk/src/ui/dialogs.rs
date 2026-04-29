// Diálogos simples do Mocha App Picker GTK.

use adw::prelude::*;
use gtk::prelude::*;

use crate::catalog::{Note, NoteLevel};

pub fn show_message(
    parent: &adw::ApplicationWindow,
    message_type: gtk::MessageType,
    message: &str,
) {
    let dialog = gtk::MessageDialog::builder()
        .transient_for(parent)
        .modal(true)
        .message_type(message_type)
        .buttons(gtk::ButtonsType::Ok)
        .text(message)
        .build();

    dialog.connect_response(|dialog, _| {
        dialog.close();
    });

    dialog.present();
}

pub fn show_note(parent: &adw::ApplicationWindow, note: &Note, close_label: &str) {
    let message_type = match note.level {
        NoteLevel::Info => gtk::MessageType::Info,
        NoteLevel::Warning => gtk::MessageType::Warning,
        NoteLevel::Caution => gtk::MessageType::Warning,
    };

    let dialog = gtk::MessageDialog::builder()
        .transient_for(parent)
        .modal(true)
        .message_type(message_type)
        .buttons(gtk::ButtonsType::None)
        .text(&note.title)
        .secondary_text(&note.body)
        .build();

    dialog.add_button(close_label, gtk::ResponseType::Close);

    dialog.connect_response(|dialog, _| {
        dialog.close();
    });

    dialog.present();
}
