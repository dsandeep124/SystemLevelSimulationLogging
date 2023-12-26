classdef eventLogger < handle
    %   Copyright 2023 The MathWorks, Inc.

    properties
        Nodes
        DisplayEventLogs=true

        % Logged nodes properties
        bluetoothNode
        bluetoothLENode
        wlanNode
    end

    methods
        function obj=eventLogger(nodes, simulationTime, varargin)
            % Properties initialization
            availableNodeTypes={'bluetoothNode', 'bluetoothLENode', 'wlanNode'};
            for nodeTypeID=1:numel(availableNodeTypes)
                currentNodeClass = availableNodeTypes{nodeTypeID};
                metadata = eval(['?' currentNodeClass]);
                eventList = arrayfun(@(x) x.Name, metadata.EventList, UniformOutput=false);
                eventList = setdiff(eventList, 'ObjectBeingDestroyed');
                for idx=1:numel(eventList)
                    obj.(currentNodeClass).(eventList{idx})={};
                end
            end

            if iscell(nodes)
                nodes=cellfun(@(x) x,nodes,UniformOutput=false);
            else
                nodes=arrayfun(@(x) x,nodes,UniformOutput=false);
            end
            obj.Nodes=nodes;
            for idx=1:numel(obj.Nodes)
                currNode = obj.Nodes{idx};
                metaData = eval(['?' class(currNode)]);
                eventList = arrayfun(@(x) string(x.Name), [metaData.EventList]);
                eventList = setdiff(eventList, "ObjectBeingDestroyed");
                for jdx=1:numel(eventList)
                    addlistener(currNode, eventList(jdx), @(varargin)obj.appendEventLogs(varargin{:}));
                end
            end

            if nargin==4 && strcmpi(varargin{1},"DisplayEventLogs") && varargin{2}
                netsim=wirelessNetworkSimulator.getInstance();
                netsim.scheduleAction(@(x,y) obj.showEventLogs(), [], simulationTime);
            end
        end

        function showEventLogs(obj)
            nodes = obj.Nodes;
            nodeTypes = unique(cellfun(@(x) string(class(x)), nodes));
            for idx = 1:numel(nodeTypes)
                logs = obj.(nodeTypes(idx));
                slsEventLogger(logs, nodeTypes(idx));
            end
        end

        function appendEventLogs(obj, currNode, eventData)
            currentNodeType=class(currNode);
            switch currentNodeType
                case 'bluetoothNode'
                    switch(eventData.EventName)
                        case 'PacketTransmissionStarted'
                            tmpTable = table(...
                                eventData.Data.CurrentTime, ...
                                eventData.Source.Name, ...
                                eventData.Data.LTAddress, ...
                                eventData.Data.TransmittedPower, ...
                                eventData.Data.PacketDuration, ...
                                {eventData.Data.Payload}, ...
                                eventData.Data.ChannelIndex, ...
                                string(eventData.Data.PacketType), ...
                                string(eventData.Data.PHYMode), ...
                                eventData.Data.ARQN, ...
                                eventData.Data.SEQN, ...
                                'VariableNames', {...
                                'Timestamp', 'Source', ...
                                'LTAddress', 'TransmittedPower', 'PacketDuration', 'Payload', 'ChannelIndex', 'PacketType', 'PHYMode', 'ARQN', 'SEQN'});

                        case 'PacketReceptionEnded'
                            tmpTable = table(...
                                eventData.Data.CurrentTime, eventData.Data.SourceNodeName, currNode.Name, ...
                                eventData.Data.LTAddress, ...
                                eventData.Data.SuccessStatus, ...
                                eventData.Data.ReceivedPower, ...
                                eventData.Data.SINR, ...
                                eventData.Data.PacketDuration, ...
                                {eventData.Data.DataPayload}, ...
                                {eventData.Data.VoicePayload}, ...
                                string(eventData.Data.PacketType), ...
                                string(eventData.Data.PHYMode), ...
                                eventData.Data.ChannelIndex, ...
                                eventData.Data.ARQN, ...
                                eventData.Data.SEQN, ...
                                'VariableNames', {'Timestamp', 'Source', 'Destination', ...
                                'LTAddress', 'SuccessStatus', 'ReceivedPower', 'SINR', 'PacketDuration', ...
                                'DataPayload', 'VoicePayload', 'PacketType', 'PHYMode', 'ChannelIndex', 'ARQN', 'SEQN'});

                        case 'AppDataReceived'
                            tmpTable = table(...
                                eventData.Data.CurrentTime, eventData.Data.SourceNodeName, currNode.Name, ...
                                eventData.Data.PacketGenerationTime, ...
                                {eventData.Data.Packet}, ...
                                eventData.Data.PacketLength, ...
                                'VariableNames', {'Timestamp', 'Source', 'Destination', 'PacketGenerationTime', 'Packet', 'PacketLength'});


                        case 'ChannelMapUpdated'
                            tmpTable = table(...
                                eventData.Data.CurrentTime, eventData.Data.SourceNodeName, currNode.Name, ...
                                num2str(eventData.Data.UpdatedChannelList), ...
                                'VariableNames', {'Timestamp', 'Source', 'Destination', 'UpdatedChannelList'});

                        otherwise
                            return;
                    end

                case 'bluetoothLENode'
                    switch(eventData.EventName)
                        case 'PacketTransmissionStarted'
                            tmpTable = table(...
                                eventData.Data.CurrentTime, eventData.Source.Name, ...
                                eventData.Data.PacketDuration, string(eventData.Data.AccessAddress), ...
                                eventData.Data.ChannelIndex, string(eventData.Data.PHYMode), ...
                                eventData.Data.TransmittedPower, {eventData.Data.PDU}, ...
                                'VariableNames', {'Timestamp', 'Source', ...
                                'PacketDuration', 'AccessAddress', 'ChannelIndex', 'PHYMode', 'TransmittedPower', 'PDU'});

                        case 'PacketReceptionEnded'
                            tmpTable = table(...
                                eventData.Data.CurrentTime, eventData.Data.SourceNode, currNode.Name, ...
                                eventData.Data.AccessAddress, ...
                                eventData.Data.SuccessStatus, ...
                                eventData.Data.ReceivedPower, ...
                                eventData.Data.SINR, ...
                                eventData.Data.PacketDuration, ...
                                {eventData.Data.PDU}, ...
                                string(eventData.Data.PHYMode), ...
                                eventData.Data.ChannelIndex, ...
                                'VariableNames', {...
                                'Timestamp', 'Source', 'Destination', ...
                                'AccessAddress', 'SuccessStatus', 'ReceivedPower', 'SINR', 'PacketDuration', 'PDU', 'PHYMode', 'ChannelIndex'});

                        case 'AppDataReceived'
                            tmpTable = table(...
                                eventData.Data.CurrentTime, eventData.Data.SourceNode, currNode.Name, ...
                                {eventData.Data.ReceivedData}, ...
                                'VariableNames', {'Timestamp', 'Source', 'Destination', 'ReceivedData'});

                        case 'ChannelMapUpdated'
                            tmpTable = table(...
                                eventData.Data.CurrentTime, eventData.Data.PeerNode, currNode.Name, ...
                                num2str(eventData.Data.UpdatedChannelList), ...
                                'VariableNames', {'Timestamp', 'Source', 'Destination', 'UpdatedChannelList'});

                        case 'MeshAppDataReceived'
                            tmpTable = table(...
                                eventData.Data.CurrentTime, string(eventData.Data.SourceAddress), string(eventData.Data.DestinationAddress), ...
                                {eventData.Data.Message}, ...
                                'VariableNames', {'Timestamp', 'Source', 'Destination', 'Message'});


                        case 'ConnectionEventEnded'
                            tmpTable = table(eventData.Data.CurrentTime, eventData.Source.Name, ...
                                eventData.Data.Counter, eventData.Data.TransmittedPackets, ...
                                eventData.Data.ReceivedPackets, eventData.Data.CRCFailedPackets, ...
                                'VariableNames', {'Timestamp', 'Source', ...
                                'Counter', 'TransmittedPackets', 'ReceivedPackets', 'CRCFailedPackets'});

                        otherwise
                            return;
                    end

                case 'wlanNode'
                    switch(eventData.EventName)
                        case 'StateChanged'
                            tmpTable = table(eventData.Data.CurrentTime, eventData.Source.Name, ...
                                eventData.Data.DeviceID, string(eventData.Data.State), eventData.Data.Duration, ...
                                'VariableNames', {'Timestamp', 'Source', ...
                                'DeviceID', 'State', 'Duration'});

                        case 'MPDUGenerated'
                            tmpTable = table(eventData.Data.CurrentTime, eventData.Source.Name, ...
                                eventData.Data.DeviceID, eventData.Data.Frequency, eventData.Data.MPDU, ...
                                'VariableNames', {'Timestamp', 'Source', ...
                                'DeviceID', 'Frequency', 'MPDU'});

                        case 'MPDUDecoded'
                            tmpTable = table( ...
                                eventData.Data.CurrentTime, eventData.Source.Name, ...
                                eventData.Data.DeviceID, eventData.Data.Frequency, ...
                                string(num2str(eventData.Data.FCSFail')), ...
                                string(eventData.Data.MPDU.FrameType), ...
                                string(eventData.Data.MPDU .FrameFormat), ...
                                eventData.Data.MPDU.Duration, ...
                                string(eventData.Data.MPDU.AckPolicy), ...
                                'VariableNames', {'Timestamp', 'Source', ...
                                'DeviceID', 'Frequency', 'FCSFail', ...
                                'FrameType', 'FrameFormat', 'Duration', 'AckPolicy'});

                        case 'TransmissionStatus'
                            tmpTable = table(eventData.Data.CurrentTime, eventData.Source.Name, ...
                                eventData.Data.DeviceID, string(eventData.Data.FrameType), ...
                                eventData.Data.ReceiverNodeID, ...
                                string(num2str(eventData.Data.MPDUSuccess')), ...
                                string(num2str(eventData.Data.MPDUDiscarded')), ...
                                string(num2str(eventData.Data.TimeInQueue')), ...
                                string(num2str(eventData.Data.AccessCategory')), ...
                                eventData.Data.ResponseRSSI, ...
                                'VariableNames', {'Timestamp', 'Source', ...
                                'DeviceID', 'FrameType', 'ReceiverNodeID', 'MPDUSuccess', 'MPDUDiscarded', 'TimeInQueue', ...
                                'AccessCategory', 'ResponseRSSI'});

                        case 'AppDataReceived'
                            netsim = wirelessNetworkSimulator.getInstance();
                            srcIDs = unique(eventData.Data.SourceNodeID);
                            srcNames = strjoin(arrayfun(@(x) netsim.Nodes{x}.Name, srcIDs), ', ');

                            tmpTable = table(...
                                eventData.Data.CurrentTime, srcNames, currNode.Name, ...
                                eventData.Data.PacketGenerationTime, eventData.Data.AccessCategory, ...
                                eventData.Data.PacketLength, ...
                                {eventData.Data.Packet}, ...
                                'VariableNames', {'Timestamp', 'Source', 'Destination', ...
                                'PacketGenerationTime', 'AccessCategory', 'PacketLength', 'Packet'});

                        otherwise
                            return;
                    end
            end
            obj.(currentNodeType).(eventData.EventName) = [obj.(currentNodeType).(eventData.EventName);tmpTable];
        end
    end
end