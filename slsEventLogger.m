classdef slsEventLogger < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        GridLayout             matlab.ui.container.GridLayout
        LeftPanel              matlab.ui.container.Panel
        FILTERSLabel           matlab.ui.control.Label
        NodeNamesListBox       matlab.ui.control.ListBox
        NodeNamesListBoxLabel  matlab.ui.control.Label
        EventsListBox          matlab.ui.control.ListBox
        EventsListBoxLabel     matlab.ui.control.Label
        RightPanel             matlab.ui.container.Panel
        EventDataLabel         matlab.ui.control.Label
        Label                  matlab.ui.control.Label
        EventsTable            matlab.ui.control.Table
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = public)
        LoggedEvents % Structure of logged events
    end
    
    methods (Access = private)        
        function fillFiltersAndEventTable(app, currentEventName, varargin)
            currentEventLog=app.LoggedEvents.(currentEventName);
            if(isempty(currentEventLog))
                app.NodeNamesListBox.Items={};
                app.NodeNamesListBox.Value={};
                app.EventsTable.ColumnName={};
                app.EventsTable.Data = {};
            else
                if nargin==2
                    nodeNames=[];
                    if any(strcmp(fieldnames(currentEventLog), 'Source'))
                        nodeNames = currentEventLog.Source;
                    end
                    if any(strcmp(fieldnames(currentEventLog), 'Destination'))
                        nodeNames = [nodeNames; currentEventLog.Destination];
                    end

                    app.NodeNamesListBox.Items=["All"; unique(nodeNames)];
                    app.NodeNamesListBox.Value="All";

                    app.EventsTable.ColumnName=currentEventLog.Properties.VariableNames;
                    tableData = currentEventLog;
                else
                    nodeNameFilter=varargin{1};
                    indexes=[];
                    if any(strcmp(fieldnames(currentEventLog), 'Source'))
                        indexes = strcmp(currentEventLog.Source, nodeNameFilter);
                    end
                    if any(strcmp(fieldnames(currentEventLog), 'Destination'))
                        indexes = indexes | strcmp(currentEventLog.Destination, nodeNameFilter);
                    end
                    tableData = currentEventLog(indexes,:);
                end                
                app.EventsTable.Data = tableData;
            end
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, loggedEvents, figTitle)
            app.UIFigure.Name = sprintf('SLS Event Viewer (%s)', figTitle);
            eventsList=fieldnames(loggedEvents);
            app.LoggedEvents=loggedEvents;
            app.EventsListBox.Items=eventsList;
            nodeNames=[];
            for idx=1:numel(eventsList)
                currentEventLog = loggedEvents.(eventsList{idx});
                if ~isempty(currentEventLog)
                    app.EventsListBox.Value=eventsList{idx};
                    if any(strcmp(fieldnames(currentEventLog), 'Source'))
                        nodeNames = currentEventLog.Source;
                    end
                    if any(strcmp(fieldnames(currentEventLog), 'Destination'))
                        nodeNames = [nodeNames; currentEventLog.Destination]; %#ok<*AGROW>
                    end

                    app.NodeNamesListBox.Items=["All"; unique(nodeNames)];
                    app.NodeNamesListBox.Value="All";
                    app.EventsTable.ColumnName=currentEventLog.Properties.VariableNames;
                    app.EventsTable.Data = currentEventLog;
                    return;
                end
            end
        end

        % Selection changed function: EventsTable
        function EventsTableSelectionChanged(app, event)
            selection = app.EventsTable.Selection;            
        end

        % Value changed function: EventsListBox
        function EventsListBoxValueChanged(app, event)
            value = app.EventsListBox.Value;
            app.fillFiltersAndEventTable(value);
        end

        % Value changed function: NodeNamesListBox
        function NodeNamesListBoxValueChanged(app, event)
            value = app.NodeNamesListBox.Value;
            if strcmpi(value,'all')
                app.fillFiltersAndEventTable(app.EventsListBox.Value);
            else
                app.fillFiltersAndEventTable(app.EventsListBox.Value, value);
            end
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {593, 593};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {274, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 925 593];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {274, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create EventsListBoxLabel
            app.EventsListBoxLabel = uilabel(app.LeftPanel);
            app.EventsListBoxLabel.HorizontalAlignment = 'right';
            app.EventsListBoxLabel.Position = [6 531 42 22];
            app.EventsListBoxLabel.Text = 'Events';

            % Create EventsListBox
            app.EventsListBox = uilistbox(app.LeftPanel);
            app.EventsListBox.Items = {};
            app.EventsListBox.ValueChangedFcn = createCallbackFcn(app, @EventsListBoxValueChanged, true);
            app.EventsListBox.Position = [63 379 202 176];
            app.EventsListBox.Value = {};

            % Create NodeNamesListBoxLabel
            app.NodeNamesListBoxLabel = uilabel(app.LeftPanel);
            app.NodeNamesListBoxLabel.HorizontalAlignment = 'right';
            app.NodeNamesListBoxLabel.WordWrap = 'on';
            app.NodeNamesListBoxLabel.Position = [6 319 42 36];
            app.NodeNamesListBoxLabel.Text = 'Node Names';

            % Create NodeNamesListBox
            app.NodeNamesListBox = uilistbox(app.LeftPanel);
            app.NodeNamesListBox.Items = {'All'};
            app.NodeNamesListBox.ValueChangedFcn = createCallbackFcn(app, @NodeNamesListBoxValueChanged, true);
            app.NodeNamesListBox.Position = [63 7 202 350];
            app.NodeNamesListBox.Value = 'All';

            % Create FILTERSLabel
            app.FILTERSLabel = uilabel(app.LeftPanel);
            app.FILTERSLabel.HorizontalAlignment = 'center';
            app.FILTERSLabel.FontWeight = 'bold';
            app.FILTERSLabel.Position = [6 565 262 22];
            app.FILTERSLabel.Text = 'FILTERS';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create EventsTable
            app.EventsTable = uitable(app.RightPanel);
            app.EventsTable.ColumnName = '';
            app.EventsTable.RowName = {};
            app.EventsTable.ColumnSortable = true;
            app.EventsTable.SelectionChangedFcn = createCallbackFcn(app, @EventsTableSelectionChanged, true);
            app.EventsTable.Multiselect = 'off';
            app.EventsTable.Position = [15 157 631 409];

            % Create EventDataLabel
            app.EventDataLabel = uilabel(app.RightPanel);
            app.EventDataLabel.HorizontalAlignment = 'center';
            app.EventDataLabel.FontWeight = 'bold';
            app.EventDataLabel.Position = [15 565 630 22];
            app.EventDataLabel.Text = 'Event Data';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = slsEventLogger(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end