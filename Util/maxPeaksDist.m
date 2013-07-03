function [peaks indices] = maxPeaksDist(x, dist, varargin)
%MAXPEAKSDIST Find the maximum peaks in a vector. The peaks
%are separated by, at least, the given distance.
%
%   [PEAKS INDICES] = MAXPEAKSDIST(X, DIST)
%
%   [PEAKS INDICES] = MAXPEAKSDIST(X, DIST, CHAINCODELENGTHS)
%
%   Inputs:
%       x                - the vector of values
%       dist             - the minimum distance between peaks
%       chainCodeLengths - the chain-code length at each index;
%                          if empty, the array indices are used instead
%
%   Outputs:
%       peaks   - the maximum peaks
%       indices - the indices for the peaks
%
%   See also MINPEAKSDIST, COMPUTECHAINCODELENGTHS

% Are there chain-code lengths?
if length(varargin) == 1
    chainCodeLengths = varargin{1};
else
    chainCodeLengths = [];
end

% Use the array indices for length.
if isempty(chainCodeLengths)
    chainCodeLengths = 1:length(x);
end

% Is the vector larger than the search window?
winSize = 2 * dist + 1;
if chainCodeLengths(end) < winSize
    [peaks indices] = max(x);
    return;
end

% Initialize the peaks and indices.
wins = ceil(length(x) / winSize);
peaks = zeros(wins, 1); % pre-allocate memory
indices = zeros(wins, 1); % pre-allocate memory

% Search for peaks.
im = 0; % the last maxima index
ie = 0; % the end index for the last maxima's search window
ip = 1; % the current, potential, max peak index
p = x(ip); % the current, potential, max peak value
i = 2; % the vector index
j = 1; % the recorded, maximal peaks index
while i <= length(x)
    
    % Found a potential peak.
    if (isnan(p) && ~isnan(x(i))) || x(i) > p
        ip = i;
        p = x(i);
    end
    
    % Test the potential peak.
    if ~isnan(p) && (chainCodeLengths(i) - chainCodeLengths(ip) >= dist ...
            || i == length(x))
        
        % Check the untested values next to the previous maxima.
        if im > 0 && chainCodeLengths(ip) - chainCodeLengths(im) <= 2 * dist
            
            % Check the untested values next to the previous maxima. 
            isMax = true;
            k = ie;
            while isMax && k > 0 && ...
                    chainCodeLengths(ip) - chainCodeLengths(k) < dist
                
                % Is the previous peak larger?
                if x(ip) <= x(k)
                    isMax = false;
                end
                
                % Advance.
                k = k - 1;
            end
            
            % Record the peak.
            if isMax
                indices(j) = ip;
                peaks(j) = p;
                j = j + 1;
            end
            
            % Record the maxima.
            im = ip;
            ie = i;
            ip = i;
            p = x(ip);
            
        % Record the peak.
        else
            indices(j) = ip;
            peaks(j) = p;
            j = j + 1;
            im = ip;
            ie = i;
            ip = i;
            p = x(ip);
        end
    end
        
    % Advance.
    i = i + 1;
end

% Collapse any extra memory.
indices(j:end) = [];
peaks(j:end) = [];
end