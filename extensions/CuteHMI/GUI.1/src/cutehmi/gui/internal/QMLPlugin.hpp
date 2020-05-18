#ifndef H_EXTENSIONS_CUTEHMI_GUI_1_SRC_CUTEHMI_GUI_INTERNAL_QMLPLUGIN_HPP
#define H_EXTENSIONS_CUTEHMI_GUI_1_SRC_CUTEHMI_GUI_INTERNAL_QMLPLUGIN_HPP

#include <QQmlExtensionPlugin>

class QJSEngine;

namespace cutehmi {
namespace gui {
namespace internal {

class QMLPlugin:
	public QQmlExtensionPlugin
{
		Q_OBJECT
		Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

	public:
		void registerTypes(const char * uri) override;

		//<CuteHMI.LockScreen-1.workaround target="Qt" cause="design">
		static QObject * CuteApplicationProvider(QQmlEngine * engine, QJSEngine * scriptEngine);
		//</CuteHMI.LockScreen-1.workaround>

		static QObject * ThemeProvider(QQmlEngine * engine, QJSEngine * scriptEngine);
};


}
}
}

#endif

//(c)C: Copyright © 2020, Michał Policht <michal@policht.pl>. All rights reserved.
//(c)C: This file is a part of CuteHMI.
//(c)C: CuteHMI is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//(c)C: CuteHMI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.
//(c)C: You should have received a copy of the GNU Lesser General Public License along with CuteHMI.  If not, see <https://www.gnu.org/licenses/>.
