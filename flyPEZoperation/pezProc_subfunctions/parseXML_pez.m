function final_dataset = parseXML_pez(filename)

% PARSEXML Convert XML file to a MATLAB structure.
try
   tree = xmlread(filename);
catch
   error('Failed to read XML file %s.',filename);
end

% Recurse over child nodes. This could run into problems 
% with very deeply nested trees.
try
   final_list = parseChildNodes(tree,[]);
   logicalA = ~strcmp(final_list(:,1),'#text');        %removes excess flags for ends of statements
   logicalB = cellfun(@isempty,final_list(:,1),'UniformOutput',false);
   logicalB = cell2mat(logicalB) == 0;
   final_list = final_list(min([logicalA logicalB],[],2),:);
   varspecs = final_list(:,2)';
   varnames = final_list(:,1)';
   final_dataset = dataset([{varspecs},varnames]);
catch
   error('Unable to parse XML file %s.',filename);
end


% ----- Local function PARSECHILDNODES -----
function final_list = parseChildNodes(theNode,final_list)
% Recurse over node children.

if theNode.hasChildNodes
   childNodes = theNode.getChildNodes;
   numChildNodes = childNodes.getLength;

    for count = 1:numChildNodes
        theChild = childNodes.item(count-1);
        final_list = makeStructFromNode(theChild,final_list,length(final_list));
    end
end

% ----- Local function MAKESTRUCTFROMNODE -----
function final_list = makeStructFromNode(theNode,final_list,idx)
if(idx == 0)
    final_list = cell(1, 2);
end

[~,final_list]= parseAttributes(theNode,final_list,length(final_list));
final_list = parseChildNodes(theNode,final_list);

% ----- Local function PARSEATTRIBUTES -----
function [attributes,final_list] = parseAttributes(theNode,final_list,idx)
% Create attributes structure.

attributes = [];
if theNode.hasAttributes
   theAttributes = theNode.getAttributes;
   numAttributes = theAttributes.getLength;
   allocCell = cell(1, numAttributes);
   attributes = struct('Name', allocCell, 'Value', ...
                       allocCell);

   for count = 1:numAttributes
      attrib = theAttributes.item(count-1);
      attributes(count).Name = char(attrib.getName);
      attributes(count).Value = char(attrib.getValue);
      final_list{count+idx,1}= char(attrib.getName);
      final_list{count+idx,2}= char(attrib.getValue);
   end
else
  final_list{idx+1,1}= char(theNode.getNodeName);
  theChild = theNode.getChildNodes.item(0);
  if isempty(theChild)
  else
     final_list{idx+1,2}= char(theChild.getData);
  end
end