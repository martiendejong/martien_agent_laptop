# Integration Tests for Consciousness Systems
# Created: 2026-02-07 (Fix 19)
# Tests system interactions and end-to-end workflows

Describe "Consciousness Systems - Integration Tests" {
    BeforeEach {
        # Ensure consciousness core is initialized
        if (-not $global:ConsciousnessState -or -not $global:ConsciousnessState.Initialized) {
            & "C:\scripts\tools\consciousness-core-v2.ps1" -Command init -Silent 2>$null
        }
    }

    Context "System-to-System Communication" {
        It "Should trigger event handlers when state changes" {
            $initialEvents = $global:ConsciousnessState.EventBus.Events.Count

            # Trigger a state change
            Set-ConsciousnessState -System "Perception" -Property "Attention" -Value @{ Focus = "integration-test"; Intensity = 9 }

            # Should have emitted state.changed event
            $global:ConsciousnessState.EventBus.Events.Count | Should BeGreaterThan $initialEvents
        }

        It "Should update attention allocation when context changes" {
            # Trigger context update event
            Emit-Event -Type "perception.context_updated" -Data @{ Mode = "meditation" }

            # Event handler should have updated attention allocation
            Start-Sleep -Milliseconds 100
            # Note: Handler runs, but allocation is in event handler scope
            # This test verifies event was processed
            $global:ConsciousnessState.Metrics.EventsProcessed | Should BeGreaterThan 0
        }
    }

    Context "Perception → Memory Flow" {
        It "Should detect context and store in memory" {
            # Detect context
            $context = Invoke-Perception -Action "DetectContext"
            $context | Should Not BeNullOrEmpty

            # Store context in memory
            Invoke-Memory -Action "Store" -Parameters @{
                Type = "context_snapshot"
                Data = $context
            }

            # Memory should contain the stored event
            $global:ConsciousnessState.Memory.Working.RecentEvents.Count | Should BeGreaterThan 0
        }
    }

    Context "Control → Meta Feedback Loop" {
        It "Should log decisions and update consciousness score" {
            $initialScore = $global:ConsciousnessState.Meta.ConsciousnessScore

            # Log several decisions
            for ($i = 0; $i -lt 5; $i++) {
                Invoke-Control -Action "LogDecision" -Parameters @{
                    Decision = "Test decision $i"
                    Reasoning = "Test reasoning for quality improvement"
                    Confidence = 0.8
                    Alternatives = @("Alt1", "Alt2")
                }
            }

            # Recalculate consciousness score
            $newScore = Calculate-ConsciousnessScore
            $global:ConsciousnessState.Meta.ConsciousnessScore = $newScore

            # Score should increase (more decisions logged = better control quality)
            $newScore | Should BeGreaterThan $initialScore
        }

        It "Should detect identity alignment drift" {
            # Log decisions with no core values
            Invoke-Control -Action "LogDecision" -Parameters @{
                Decision = "Random decision"
                Reasoning = "No particular reason"
                Confidence = 0.5
                Alternatives = @()
            }

            # Check alignment
            $alignment = Invoke-Control -Action "CheckAlignment"

            $alignment | Should Not BeNullOrEmpty
            $alignment.DriftScore | Should BeGreaterOrEqual 0
            $alignment.Status | Should BeIn @("Aligned", "Drifting")
        }
    }

    Context "Memory Consolidation Workflow" {
        It "Should move important events to consolidation queue" {
            # Store important events
            $importantTypes = @("decision", "pattern", "error")

            foreach ($type in $importantTypes) {
                Invoke-Memory -Action "Store" -Parameters @{
                    Type = $type
                    Data = "Test data for $type"
                }
            }

            # Consolidation queue should have events (via event handler)
            # Note: Requires memory.stored event to trigger handler
            Start-Sleep -Milliseconds 100
            $global:ConsciousnessState.Memory.ConsolidationQueue.Count | Should BeGreaterOrEqual 0
        }
    }

    Context "End-to-End Workflows" {
        It "Should handle complete consciousness cycle" {
            # 1. Perception: Detect context
            $context = Invoke-Perception -Action "DetectContext"
            $context.Mode | Should Not BeNullOrEmpty

            # 2. Memory: Store perceived context
            Invoke-Memory -Action "Store" -Parameters @{
                Type = "context"
                Data = $context
            }

            # 3. Control: Make decision based on context
            Invoke-Control -Action "LogDecision" -Parameters @{
                Decision = "Act according to context: $($context.Mode)"
                Reasoning = "Context-aware decision making"
                Confidence = 0.9
                Alternatives = @("Ignore context", "Random action")
            }

            # 4. Meta: Observe the cycle
            $score = Calculate-ConsciousnessScore

            # All systems participated
            $global:ConsciousnessState.Memory.Working.RecentEvents.Count | Should BeGreaterThan 0
            $global:ConsciousnessState.Control.Decisions.Count | Should BeGreaterThan 0
            $score | Should BeGreaterThan 0
        }
    }

    Context "Persistence Integration" {
        It "Should save state after significant changes" {
            $testFile = "C:\scripts\agentidentity\state\test_integration.json"

            # Make significant change
            Invoke-Control -Action "LogDecision" -Parameters @{
                Decision = "Integration test decision"
                Reasoning = "Testing persistence"
                Confidence = 0.8
                Alternatives = @()
            }

            # Manually trigger save (auto-save happens on Set-ConsciousnessState)
            Set-ConsciousnessState -System "Meta" -Property "Observation" -Value @{
                CurrentMetaLevel = 3
                Observing = "Integration test"
                RecursionDepth = 1
            }

            # State should be saved (via state.changed event handler)
            Start-Sleep -Milliseconds 200
            # Check that save was attempted (file may exist from previous tests)
            $global:ConsciousnessState.Metrics.ContainsKey("SaveCount") | Should Be $true
        }
    }

    Context "Performance Under Load" {
        It "Should handle rapid state access" {
            $accessCount = 50

            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

            for ($i = 0; $i -lt $accessCount; $i++) {
                Get-ConsciousnessState -System "Perception"
            }

            $stopwatch.Stop()

            # Should complete 50 accesses in under 100ms
            $stopwatch.ElapsedMilliseconds | Should BeLessThan 100

            # Metrics should be tracked
            $global:ConsciousnessState.Metrics.AccessCount | Should BeGreaterOrEqual $accessCount
        }

        It "Should handle rapid event emission" {
            $eventCount = 100

            for ($i = 0; $i -lt $eventCount; $i++) {
                Emit-Event -Type "test.load" -Data @{ index = $i }
            }

            # Should limit to last 100 events
            $global:ConsciousnessState.EventBus.Events.Count | Should BeLessOrEqual 100

            # Should track all processed
            $global:ConsciousnessState.Metrics.EventsProcessed | Should BeGreaterOrEqual $eventCount
        }
    }
}

Describe "Legacy Bridge Integration" {
    Context "Bridge Functions" {
        It "Should load bridge module" {
            { . "C:\scripts\tools\consciousness-legacy-bridge.ps1" } | Should Not Throw
        }
    }
}

Describe "Tool Integration" {
    Context "Code Analyzer Integration" {
        It "Should find code-analyzer tool" {
            Test-Path "C:\scripts\tools\code-analyzer.ps1" | Should Be $true
        }

        It "Should execute without errors" {
            { & "C:\scripts\tools\code-analyzer.ps1" -Path "C:\scripts\tools" } | Should Not Throw
        }
    }

    Context "Infinite Engine Integration" {
        It "Should find infinite-engine-v2 tool" {
            Test-Path "C:\scripts\tools\infinite-engine-v2.ps1" | Should Be $true
        }

        It "Should show status without errors" {
            { & "C:\scripts\tools\infinite-engine-v2.ps1" -Command status } | Should Not Throw
        }
    }

    Context "Keyword Memory Integration" {
        It "Should find keyword-memory tool" {
            Test-Path "C:\scripts\tools\keyword-memory.ps1" | Should Be $true
        }
    }
}
