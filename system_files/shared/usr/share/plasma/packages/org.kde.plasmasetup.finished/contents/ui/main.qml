// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2025 Kristen McWilliam <kristen@kde.org>
// SPDX-FileCopyrightText: 2026 Macrosofty
//
// SPDX-License-Identifier: GPL-2.0-or-later
//
// Macrosofty overlay of plasma-setup's "finished" screen. Shipped at the
// same path as upstream so the OCI layer wins. Only the two completion
// messages are rebranded; structure mirrors upstream so a plasma-setup
// bump is easy to re-sync. Strings stay wrapped in i18nc but become
// English-source — non-English users fall back to this English copy on
// this screen only.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasmasetup.components as PlasmaSetupComponents
import org.kde.plasmasetup

PlasmaSetupComponents.SetupModule {
    id: root

    nextEnabled: true

    /*!
    * The message shown to users who already have an account on the system.
    */
    property string existingUserFinishedMessage: i18nc( // qmllint disable unqualified
        "%1 is the distro name",
        "You're through the door — the house is yours.<br /><br />Welcome to <b>%1</b>.",
        InitialStartUtil.distroName
    )

    /*!
    * The message shown to users who have just created a new account.
    */
    property string newUserFinishedMessage: i18nc( // qmllint disable unqualified
        "%1 is the distro name",
        "You're through the door.<br /><br />Click <b>Finish</b> to sign in to your new account.<br /><br />The house is yours — welcome to <b>%1</b>.",
        InitialStartUtil.distroName
    )

    contentItem: ColumnLayout {
        id: mainColumn

        ColumnLayout {
            Layout.alignment: Qt.AlignCenter

            Label {
                id: finishedMessage
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                text: AccountController.hasExistingUsers
                        ? root.existingUserFinishedMessage
                        : root.newUserFinishedMessage
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            Image {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Kirigami.Units.gridUnit
                Layout.maximumHeight: mainColumn.height - finishedMessage.height - Kirigami.Units.gridUnit
                fillMode: Image.PreserveAspectFit
                source: "konqi-calling.png"
            }
        }
    }
}
