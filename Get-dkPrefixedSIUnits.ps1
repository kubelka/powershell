Function Get-dkPrefixedSIUnits {
    <#
        .SYNOPSIS
          Convert a decimal signed value to a prefixed SI unit with proper alignment and padding
          Disclaimer: only tested with en-US
    #>
    Param (
        [OutputType([string])]
        [Parameter ( Mandatory = $true, ValueFromPipeline = $true )]
        [System.Decimal]
        $Value,
        [int]
        $Decimals = 1,
        [ValidateSet('Binary', 'Decimal')]
        $PrefixType = 'Binary',
        [string]
        $Unit = 'B',
        [string]
        $Units = 'Bytes'
    )
    Begin {
        $prefixes = @{
            Binary = @{
                Base = [double]1024;
                Labels = @( [string]::Empty, 'Ki', 'Mi', 'Gi', 'Ti', 'Pi', 'Ei', 'Zi', 'Yi' )
            };
            Decimal = @{
                Base = [double]1000;
                Labels = @( [string]::Empty, 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y' )
            }
        }
        $prefix = $prefixes[ $PrefixType ]
        $align = 4 +  $Decimals + [Math]::Sign( $Decimals )
        $align += If ( $prefix.Base -gt 1000 ) { 2 } else { 0 }
        $pad = 1 + $align + ( @( $Units.Length ) + @( $prefix.Labels | %{ $_.Length + $Unit.Length } ) | Measure-Object -Maximum ).Maximum
        $numberFormat = '{' + ( '0,{0}:#,##0{1}' -f $align, ( '.' * [Math]::Sign( $Decimals ) + '0' * $Decimals )) + '} {1}{2}'
    }
    Process {
        $o = 0
        [decimal]$rValue = if( $Value ) {
            $o = [Math]::Floor( [Math]::Log([double][Math]::Abs( $Value ), $prefix.Base ))
            [Math]::Round( $Value / [decimal]( [Math]::Pow( $prefix.Base, $o )), $Decimals )
        } else {
            0
        }
        $u = if( $o ) { $Unit } else { $Units }
        ( $numberFormat -f $rValue, $prefix.Labels[ $o ], $u ).PadRight( $pad )
    }
    End {
    }
}
